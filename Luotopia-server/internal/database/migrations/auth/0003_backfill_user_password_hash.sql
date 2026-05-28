ALTER TABLE auth_users ADD COLUMN IF NOT EXISTS password_hash TEXT;

DO $$
BEGIN
  IF to_regclass('auth_password_credentials') IS NOT NULL THEN
    EXECUTE '
      UPDATE auth_users AS u
      SET password_hash = c.password_hash
      FROM auth_password_credentials AS c
      WHERE u.id = c.user_id
        AND u.password_hash IS NULL
    ';
  END IF;
END $$;
