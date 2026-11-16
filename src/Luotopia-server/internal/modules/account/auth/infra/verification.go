package infra

import (
	"context"
	"fmt"
	"log/slog"
	"net/smtp"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/account/auth/domain"
	"github.com/openwhu/luotopia/server/internal/platform/config"
	"github.com/redis/go-redis/v9"
	tcommon "github.com/tencentcloud/tencentcloud-sdk-go/tencentcloud/common"
	"github.com/tencentcloud/tencentcloud-sdk-go/tencentcloud/common/profile"
	sms "github.com/tencentcloud/tencentcloud-sdk-go/tencentcloud/sms/v20210111"
)

type RedisVerificationCodeStore struct {
	client *redis.Client
}

func NewRedisVerificationCodeStore(client *redis.Client) RedisVerificationCodeStore {
	return RedisVerificationCodeStore{client: client}
}

func (s RedisVerificationCodeStore) Save(ctx context.Context, target string, purpose domain.VerificationPurpose, code string, expiresAt time.Time) error {
	return s.client.Set(ctx, verificationKey(target, purpose), code, time.Until(expiresAt)).Err()
}

func (s RedisVerificationCodeStore) Verify(ctx context.Context, target string, purpose domain.VerificationPurpose, code string) error {
	key := verificationKey(target, purpose)
	value, err := s.client.Get(ctx, key).Result()
	if err != nil || value != code {
		return domain.ErrVerificationFailed
	}
	_ = s.client.Del(ctx, key).Err()
	return nil
}

type CompositeVerificationSender struct {
	SMS    *TencentSMSSender
	Email  *SMTPSender
	Logger *slog.Logger
}

func (s CompositeVerificationSender) Send(ctx context.Context, targetType domain.IdentityType, target string, code string, purpose domain.VerificationPurpose) error {
	switch targetType {
	case domain.IdentityPhone:
		if s.SMS == nil || !s.SMS.Enabled() {
			return domain.ErrSocialProviderDisabled
		}
		return s.SMS.Send(ctx, target, code, purpose)
	case domain.IdentityEmail:
		if s.Email == nil || !s.Email.Enabled() {
			return domain.ErrSocialProviderDisabled
		}
		return s.Email.Send(ctx, target, code, purpose)
	default:
		return domain.ErrInvalidArgument
	}
}

type TencentSMSSender struct {
	cfg config.SMSConfig
}

func NewTencentSMSSender(cfg config.SMSConfig) *TencentSMSSender {
	return &TencentSMSSender{cfg: cfg}
}

func (s TencentSMSSender) Enabled() bool {
	return s.cfg.TencentSecretID != "" && s.cfg.TencentSecretKey != "" && s.cfg.TencentAppID != "" && s.cfg.TencentSignName != "" && s.cfg.TencentTemplateID != ""
}

func (s TencentSMSSender) Send(_ context.Context, phone string, code string, _ domain.VerificationPurpose) error {
	credential := tcommon.NewCredential(s.cfg.TencentSecretID, s.cfg.TencentSecretKey)
	cpf := profile.NewClientProfile()
	client, err := sms.NewClient(credential, s.cfg.TencentRegion, cpf)
	if err != nil {
		return err
	}
	request := sms.NewSendSmsRequest()
	request.SmsSdkAppId = tcommon.StringPtr(s.cfg.TencentAppID)
	request.SignName = tcommon.StringPtr(s.cfg.TencentSignName)
	request.TemplateId = tcommon.StringPtr(s.cfg.TencentTemplateID)
	request.TemplateParamSet = tcommon.StringPtrs([]string{code})
	request.PhoneNumberSet = tcommon.StringPtrs([]string{phone})
	_, err = client.SendSms(request)
	return err
}

type SMTPSender struct {
	cfg config.EmailConfig
}

func NewSMTPSender(cfg config.EmailConfig) *SMTPSender {
	return &SMTPSender{cfg: cfg}
}

func (s SMTPSender) Enabled() bool {
	return s.cfg.SMTPHost != "" && s.cfg.SMTPUsername != "" && s.cfg.SMTPPassword != "" && s.cfg.SMTPFrom != ""
}

func (s SMTPSender) Send(_ context.Context, email string, code string, purpose domain.VerificationPurpose) error {
	addr := s.cfg.SMTPHost + ":" + s.cfg.SMTPPort
	auth := smtp.PlainAuth("", s.cfg.SMTPUsername, s.cfg.SMTPPassword, s.cfg.SMTPHost)
	subject := "Luotopia 验证码"
	body := fmt.Sprintf("你的 Luotopia 验证码是 %s，用途：%s，10 分钟内有效。", code, purpose)
	from := "Luotopia <" + s.cfg.SMTPFrom + ">"
	message := []byte("From: " + from + "\r\nTo: " + email + "\r\nSubject: " + subject + "\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\n" + body)
	return smtp.SendMail(addr, auth, s.cfg.SMTPFrom, []string{email}, message)
}

func verificationKey(target string, purpose domain.VerificationPurpose) string {
	return fmt.Sprintf("auth:verification:%s:%s", purpose, target)
}
