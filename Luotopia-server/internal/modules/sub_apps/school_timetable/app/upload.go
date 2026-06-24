package app

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"sync"
	"time"
)

const defaultUploadChunkSize int64 = 4 * 1024 * 1024

var ErrUploadIncomplete = errors.New("school timetable: upload incomplete")

type UploadSession struct {
	ID            string `json:"upload_id"`
	FileName      string `json:"file_name"`
	Size          int64  `json:"size"`
	ChunkSize     int64  `json:"chunk_size"`
	UploadedBytes int64  `json:"uploaded_bytes"`
	UploadedCount int    `json:"uploaded_count"`
	TotalChunks   int    `json:"total_chunks"`
	Completed     bool   `json:"completed"`
	CreatedAt     int64  `json:"created_at"`
	UpdatedAt     int64  `json:"updated_at"`
}

type uploadSession struct {
	UploadSession
	dir    string
	chunks map[int]int64
}

type uploadManager struct {
	mu        sync.Mutex
	root      string
	chunkSize int64
	sessions  map[string]*uploadSession
}

func newUploadManager(root string) *uploadManager {
	if strings.TrimSpace(root) == "" {
		root = filepath.Join(os.TempDir(), "luotopia-school-timetable-uploads")
	}
	return &uploadManager{
		root:      root,
		chunkSize: defaultUploadChunkSize,
		sessions:  make(map[string]*uploadSession),
	}
}

func (um *uploadManager) create(fileName string, size int64) (UploadSession, error) {
	if size <= 0 {
		return UploadSession{}, fmt.Errorf("%w: empty upload", ErrInvalidPackage)
	}
	id, err := randomUploadID()
	if err != nil {
		return UploadSession{}, err
	}
	now := time.Now().UnixMilli()
	dir := filepath.Join(um.root, id)
	if err := os.MkdirAll(filepath.Join(dir, "chunks"), 0o755); err != nil {
		return UploadSession{}, err
	}
	session := &uploadSession{
		UploadSession: UploadSession{
			ID:          id,
			FileName:    filepath.Base(fileName),
			Size:        size,
			ChunkSize:   um.chunkSize,
			TotalChunks: int((size + um.chunkSize - 1) / um.chunkSize),
			CreatedAt:   now,
			UpdatedAt:   now,
		},
		dir:    dir,
		chunks: make(map[int]int64),
	}
	um.mu.Lock()
	defer um.mu.Unlock()
	um.sessions[id] = session
	return session.UploadSession, nil
}

func (um *uploadManager) get(id string) (UploadSession, bool) {
	um.mu.Lock()
	defer um.mu.Unlock()
	session, ok := um.sessions[id]
	if !ok {
		return UploadSession{}, false
	}
	return session.UploadSession, true
}

func (um *uploadManager) saveChunk(id string, index int, reader io.Reader) (UploadSession, error) {
	um.mu.Lock()
	session, ok := um.sessions[id]
	if !ok {
		um.mu.Unlock()
		return UploadSession{}, ErrNotFound
	}
	if session.Completed {
		result := session.UploadSession
		um.mu.Unlock()
		return result, nil
	}
	if index < 0 || index >= session.TotalChunks {
		um.mu.Unlock()
		return UploadSession{}, fmt.Errorf("%w: invalid chunk index", ErrInvalidPackage)
	}
	chunkPath := filepath.Join(session.dir, "chunks", fmt.Sprintf("%06d.part", index))
	um.mu.Unlock()

	tempPath := chunkPath + ".tmp"
	out, err := os.Create(tempPath)
	if err != nil {
		return UploadSession{}, err
	}
	written, copyErr := io.Copy(out, reader)
	closeErr := out.Close()
	if copyErr != nil {
		_ = os.Remove(tempPath)
		return UploadSession{}, copyErr
	}
	if closeErr != nil {
		_ = os.Remove(tempPath)
		return UploadSession{}, closeErr
	}
	if err := os.Rename(tempPath, chunkPath); err != nil {
		_ = os.Remove(tempPath)
		return UploadSession{}, err
	}

	um.mu.Lock()
	defer um.mu.Unlock()
	session, ok = um.sessions[id]
	if !ok {
		return UploadSession{}, ErrNotFound
	}
	expectedSize := session.ChunkSize
	if index == session.TotalChunks-1 {
		expectedSize = session.Size - int64(index)*session.ChunkSize
	}
	if written != expectedSize {
		_ = os.Remove(chunkPath)
		return UploadSession{}, fmt.Errorf("%w: chunk size mismatch", ErrInvalidPackage)
	}
	if oldSize, exists := session.chunks[index]; exists {
		session.UploadedBytes -= oldSize
	}
	session.chunks[index] = written
	session.UploadedBytes += written
	session.UploadedCount = len(session.chunks)
	session.UpdatedAt = time.Now().UnixMilli()
	return session.UploadSession, nil
}

func (um *uploadManager) complete(id string) (UploadSession, error) {
	um.mu.Lock()
	session, ok := um.sessions[id]
	if !ok {
		um.mu.Unlock()
		return UploadSession{}, ErrNotFound
	}
	if session.Completed {
		result := session.UploadSession
		um.mu.Unlock()
		return result, nil
	}
	if len(session.chunks) != session.TotalChunks {
		um.mu.Unlock()
		return UploadSession{}, ErrUploadIncomplete
	}
	chunks := make([]int, 0, len(session.chunks))
	for index := range session.chunks {
		chunks = append(chunks, index)
	}
	sort.Ints(chunks)
	packagePath := filepath.Join(session.dir, "package.sqlite.gz")
	um.mu.Unlock()

	out, err := os.Create(packagePath + ".tmp")
	if err != nil {
		return UploadSession{}, err
	}
	var total int64
	for _, index := range chunks {
		chunkPath := filepath.Join(session.dir, "chunks", fmt.Sprintf("%06d.part", index))
		in, err := os.Open(chunkPath)
		if err != nil {
			_ = out.Close()
			_ = os.Remove(packagePath + ".tmp")
			return UploadSession{}, err
		}
		written, copyErr := io.Copy(out, in)
		closeErr := in.Close()
		if copyErr != nil {
			_ = out.Close()
			_ = os.Remove(packagePath + ".tmp")
			return UploadSession{}, copyErr
		}
		if closeErr != nil {
			_ = out.Close()
			_ = os.Remove(packagePath + ".tmp")
			return UploadSession{}, closeErr
		}
		total += written
	}
	closeErr := out.Close()
	if closeErr != nil {
		_ = os.Remove(packagePath + ".tmp")
		return UploadSession{}, closeErr
	}
	if err := os.Rename(packagePath+".tmp", packagePath); err != nil {
		_ = os.Remove(packagePath + ".tmp")
		return UploadSession{}, err
	}

	um.mu.Lock()
	defer um.mu.Unlock()
	session, ok = um.sessions[id]
	if !ok {
		return UploadSession{}, ErrNotFound
	}
	if total != session.Size {
		return UploadSession{}, fmt.Errorf("%w: upload size mismatch", ErrInvalidPackage)
	}
	session.Completed = true
	session.UploadedBytes = total
	session.UpdatedAt = time.Now().UnixMilli()
	return session.UploadSession, nil
}

func (um *uploadManager) packagePath(id string) (string, error) {
	um.mu.Lock()
	defer um.mu.Unlock()
	session, ok := um.sessions[id]
	if !ok {
		return "", ErrNotFound
	}
	if !session.Completed {
		return "", ErrUploadIncomplete
	}
	return filepath.Join(session.dir, "package.sqlite.gz"), nil
}

func randomUploadID() (string, error) {
	var raw [16]byte
	if _, err := rand.Read(raw[:]); err != nil {
		return "", err
	}
	return "upload_" + hex.EncodeToString(raw[:]), nil
}
