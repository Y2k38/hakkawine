CREATE TABLE settings (
    section varchar(32) NOT NULL,
    key VARCHAR(64) NOT NULL PRIMARY KEY,
    value jsonb NOT NULL,
    description varchar(255) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT NOW(),
    updated_at timestamptz NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_settings_section ON settings (section);

INSERT INTO settings (section, key, value, description)
VALUES
    -- Site
    ('site', 'site_name', '"Hakkawine"'::jsonb, 'Website display name'),
    ('site', 'site_description', '"Fast and secure network services"'::jsonb, 'Website default SEO meta description'),
    ('site', 'site_url', '"https://hakkawine.dev"'::jsonb, 'Primary domain URL for generating absolute links and callbacks'),
    ('site', 'logo_url', '"https://hakkawine.dev/assets/logo.png"'::jsonb, 'Site header logo URL'),
    ('site', 'favicon_url', '"https://hakkawine.dev/assets/favicon.ico"'::jsonb, 'Site browser tab icon URL'),
    ('site', 'tos_url', '"https://hakkawine.dev/tos"'::jsonb, 'Terms of service URL'),

    -- Security
    ('security', 'admin_path', '"a8k9m2x1"'::jsonb, 'Secure random path for admin access'),
    ('security', 'admin_login_notify', 'true'::jsonb, 'Send email notification to admin upon successful admin login'),
    ('security', 'user_ip_limit', '0'::jsonb, 'Max concurrent IP limit per user account'),

    -- i18n
    ('i18n', 'default_language', '"en"'::jsonb, 'Default fallback language when user locale is not supported'),
    ('i18n', 'supported_languages', '["en", "zh-Hans", "zh-Hant"]'::jsonb, 'List of active languages enabled in the system selector'),

    -- Currency
    ('currency', 'code', '"USD"'::jsonb, 'Primary billing currency code (ISO 4217, e.g. USD, CNY, EUR)'),
    ('currency', 'symbol', '"$"'::jsonb, 'Primary billing currency symbol displayed on frontend'),
    ('currency', 'stripe_exchange_rate', '1.0'::jsonb, 'Exchange rate multiplier for Stripe payment gateway conversion'),

    -- Email
    ('email', 'smtp_host', '"smtp.mailgun.org"'::jsonb, 'SMTP server host'),
    ('email', 'smtp_port', '465'::jsonb, 'SMTP server port'),
    ('email', 'smtp_encryption', '"ssl"'::jsonb, 'Encryption method: ssl, tls, or none'),
    ('email', 'smtp_username', '"postmaster@mg.hakkawine.dev"'::jsonb, 'SMTP auth username'),
    ('email', 'smtp_password', '"your_secret_smtp_password"'::jsonb, 'SMTP auth password'),
    ('email', 'from_address', '"noreply@hakkawine.dev"'::jsonb, 'Sender email address'),
    ('email', 'from_name', '"Hakkawine"'::jsonb, 'Sender name displayed in user inbox'),

    -- Registration
    ('registration', 'enable_register', 'true'::jsonb, 'Toggle whether new user registration is open'),
    ('registration', 'email_verify_required', 'true'::jsonb, 'Force email verification code check upon registration'),
    ('registration', 'email_whitelist_domains', '[]'::jsonb, 'Allowed email domain whitelist'),
    ('registration', 'stop_register_on_ip_limit', 'false'::jsonb, 'Restrict multi-account registration under the same IP address'),

    -- Invite
    ('invite', 'invite_only', 'false'::jsonb, 'Require invite code to register'),
    ('invite', 'default_commission_rate', '0.15'::jsonb, 'Default commission percentage for inviter'),
    ('invite', 'withdrawal_min_amount', '10.0'::jsonb, 'Minimum commission threshold required to request withdrawal'),

    -- Telegram
    ('telegram', 'telegram_bot_enable', 'false'::jsonb, 'Toggle Telegram Bot service'),
    ('telegram', 'telegram_bot_token', '""'::jsonb, 'Telegram Bot API Token for user binding and notification alerts'),
    ('telegram', 'telegram_bot_username', '""'::jsonb, 'Telegram Bot handle for quick user redirection'),

    -- Network
    ('network', 'blocked_inbound_ports', '[]'::jsonb, 'Ports blocked for inbound user allocations to prevent GFW blocking and active probing');

    -- Node labels
    ('node_label', 'country', '["hk", "kr", "jp", "tw", "us", "sg", "in", "uk", "de", "fr", "tr"]'::jsonb, 'Country'),
    ('node_label', 'isp', '[]'::jsonb, 'Internet Service Provider'),
    ('node_label', 'route', '["cn2_gia", "cn2_gt", "as9929", "as4837", "cmi", "bgp", "iplc", "iepl", "direct"]'::jsonb, 'Network Route'),
    ('node_label', 'tier', '["lite", "standard", "premium", "one_time"]'::jsonb, 'Service Tier'),
    ('node_label', 'protocol', '["vless", "hy2", "anytls", "shadowsocks"]'::jsonb, 'Supported Protocol'),
    ('node_label', 'pool', '["public", "backup"]'::jsonb, 'Resource Pool Type');
