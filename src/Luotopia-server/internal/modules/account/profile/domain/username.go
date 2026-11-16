package domain

import (
	"errors"
	"strings"
	"unicode"

	"github.com/rivo/uniseg"
	"golang.org/x/text/unicode/norm"
)

var (
	ErrUsernameEmpty   = errors.New("username_empty")
	ErrUsernameTooLong = errors.New("username_too_long")
	ErrUsernameInvalid = errors.New("username_invalid")
)

func NormalizeUsername(input string) (string, error) {
	value := strings.TrimSpace(norm.NFKC.String(input))
	if value == "" {
		return "", ErrUsernameEmpty
	}
	count := 0
	graphemes := uniseg.NewGraphemes(value)
	for graphemes.Next() {
		count++
		if count > 30 {
			return "", ErrUsernameTooLong
		}
		for _, r := range graphemes.Str() {
			if unicode.In(r, unicode.Cc, unicode.Cf) {
				return "", ErrUsernameInvalid
			}
		}
	}
	return value, nil
}
