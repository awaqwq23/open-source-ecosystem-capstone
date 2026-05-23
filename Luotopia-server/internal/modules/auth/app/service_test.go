package app_test

import (
	"context"
	"testing"

	"github.com/openwhu/luotopia/server/internal/modules/auth/app"
	"github.com/openwhu/luotopia/server/internal/modules/auth/domain"
)

func TestVerificationCodeLoginCreatesAndReusesPhoneUser(t *testing.T) {
	ctx := context.Background()
	users := app.NewMemoryUserRepository()
	codes := app.NewMemoryVerificationCodeStore()
	tokens := app.NewStaticTokenIssuer()

	service := app.NewService(app.ServiceConfig{
		Users:  users,
		Codes:  codes,
		Tokens: tokens,
	})

	if err := service.SendVerificationCode(ctx, app.SendVerificationCodeCommand{
		TargetType: domain.IdentityPhone,
		Target:     "+8613800138000",
		Purpose:    domain.VerificationPurposeLogin,
	}); err != nil {
		t.Fatalf("发送验证码失败: %v", err)
	}

	first, err := service.LoginWithVerificationCode(ctx, app.VerificationCodeLoginCommand{
		TargetType: domain.IdentityPhone,
		Target:     "+8613800138000",
		Code:       codes.LastCode("+8613800138000", domain.VerificationPurposeLogin),
		DeviceName: "Pixel 8",
	})
	if err != nil {
		t.Fatalf("首次验证码登录失败: %v", err)
	}
	if first.User.ID == "" {
		t.Fatal("首次登录应返回用户 ID")
	}
	if first.AccessToken == "" || first.RefreshToken == "" {
		t.Fatal("首次登录应返回访问令牌和刷新令牌")
	}

	if err := service.SendVerificationCode(ctx, app.SendVerificationCodeCommand{
		TargetType: domain.IdentityPhone,
		Target:     "+8613800138000",
		Purpose:    domain.VerificationPurposeLogin,
	}); err != nil {
		t.Fatalf("再次发送验证码失败: %v", err)
	}

	second, err := service.LoginWithVerificationCode(ctx, app.VerificationCodeLoginCommand{
		TargetType: domain.IdentityPhone,
		Target:     "+8613800138000",
		Code:       codes.LastCode("+8613800138000", domain.VerificationPurposeLogin),
		DeviceName: "Pixel 8",
	})
	if err != nil {
		t.Fatalf("再次验证码登录失败: %v", err)
	}
	if second.User.ID != first.User.ID {
		t.Fatalf("同一手机号应复用用户，首次=%s 再次=%s", first.User.ID, second.User.ID)
	}
}
