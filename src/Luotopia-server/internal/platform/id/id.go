package id

import (
	"crypto/rand"
	"io"
	"strings"
	"sync"

	"github.com/oklog/ulid/v2"
)

const (
	TypeUser     = "usr"
	TypeIdentity = "idt"
	TypeSession  = "sid"
)

var defaultEntropy = &lockedMonotonicReader{inner: ulid.Monotonic(rand.Reader, 0)}

type lockedMonotonicReader struct {
	mu    sync.Mutex
	inner io.Reader
}

func (r *lockedMonotonicReader) Read(p []byte) (int, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	return r.inner.Read(p)
}

func New(prefix string) string {
	id := ulid.MustNew(ulid.Now(), defaultEntropy)
	return prefix + "_" + strings.ToLower(id.String())
}

func NewRaw() string {
	id := ulid.MustNew(ulid.Now(), defaultEntropy)
	return strings.ToLower(id.String())
}

func Valid(id string, prefix string) bool {
	expected := prefix + "_"
	if !strings.HasPrefix(id, expected) {
		return false
	}
	raw := id[len(expected):]
	if len(raw) != 26 {
		return false
	}
	_, err := ulid.ParseStrict(raw)
	return err == nil
}
