package storage

import (
	"context"
	"io"
	"net/url"
	"path"
	"strings"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

type S3Config struct {
	Endpoint       string
	Bucket         string
	Region         string
	AccessKey      string
	SecretKey      string
	PublicBaseURL  string
	UseSSL         bool
	ForcePathStyle bool
}

type S3Store struct {
	client        *minio.Client
	bucket        string
	publicBaseURL string
}

func NewS3Store(cfg S3Config) (*S3Store, error) {
	client, err := minio.New(strings.TrimSpace(cfg.Endpoint), &minio.Options{
		Creds:        credentials.NewStaticV4(cfg.AccessKey, cfg.SecretKey, ""),
		Secure:       cfg.UseSSL,
		Region:       cfg.Region,
		BucketLookup: bucketLookup(cfg.ForcePathStyle),
	})
	if err != nil {
		return nil, err
	}
	return &S3Store{
		client:        client,
		bucket:        cfg.Bucket,
		publicBaseURL: strings.TrimRight(cfg.PublicBaseURL, "/"),
	}, nil
}

func (s *S3Store) Put(ctx context.Context, object Object) error {
	defer object.Body.Close()
	_, err := s.client.PutObject(ctx, s.bucket, object.Key, object.Body, object.Size, minio.PutObjectOptions{
		ContentType: object.ContentType,
	})
	return err
}

func (s *S3Store) Get(ctx context.Context, key string) (Object, error) {
	obj, err := s.client.GetObject(ctx, s.bucket, key, minio.GetObjectOptions{})
	if err != nil {
		return Object{}, err
	}
	info, err := obj.Stat()
	if err != nil {
		obj.Close()
		return Object{}, err
	}
	return Object{
		Key:         key,
		ContentType: info.ContentType,
		Size:        info.Size,
		Body:        obj,
	}, nil
}

func (s *S3Store) Delete(ctx context.Context, key string) error {
	return s.client.RemoveObject(ctx, s.bucket, key, minio.RemoveObjectOptions{})
}

func (s *S3Store) PublicURL(key string) string {
	base, err := url.Parse(s.publicBaseURL)
	if err != nil || base.Scheme == "" || base.Host == "" {
		return strings.TrimRight(s.publicBaseURL, "/") + "/" + strings.TrimLeft(key, "/")
	}
	base.Path = path.Join(base.Path, key)
	return base.String()
}

func bucketLookup(forcePathStyle bool) minio.BucketLookupType {
	if forcePathStyle {
		return minio.BucketLookupPath
	}
	return minio.BucketLookupDNS
}

var _ Store = (*S3Store)(nil)
var _ io.Reader = (*minio.Object)(nil)
