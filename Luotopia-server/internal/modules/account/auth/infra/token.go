package infra

import (
	"context"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/openwhu/luotopia/server/internal/modules/auth/domain"
)

type JWTIssuer struct {
	secret []byte
	ttl    time.Duration
}

func NewJWTIssuer(secret string, ttl time.Duration) JWTIssuer {
	if ttl <= 0 {
		ttl = 10 * time.Minute
	}
	return JWTIssuer{secret: []byte(secret), ttl: ttl}
}

func (i JWTIssuer) Issue(_ context.Context, user domain.User, session domain.Session) (string, int64, error) {
	now := time.Now()
	expiresAt := now.Add(i.ttl)
	claims := jwt.MapClaims{
		"sub": user.ID,
		"sid": session.ID,
		"iat": now.Unix(),
		"exp": expiresAt.Unix(),
	}
	token, err := jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString(i.secret)
	if err != nil {
		return "", 0, err
	}
	return token, int64(i.ttl.Seconds()), nil
}

func ParseAccessToken(secret string, raw string) (string, string, error) {
	token, err := jwt.Parse(raw, func(token *jwt.Token) (any, error) {
		return []byte(secret), nil
	}, jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Alg()}))
	if err != nil {
		return "", "", err
	}
	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok || !token.Valid {
		return "", "", jwt.ErrTokenInvalidClaims
	}
	userID, _ := claims["sub"].(string)
	sessionID, _ := claims["sid"].(string)
	if userID == "" || sessionID == "" {
		return "", "", jwt.ErrTokenInvalidClaims
	}
	return userID, sessionID, nil
}
