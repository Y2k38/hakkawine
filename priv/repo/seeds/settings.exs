alias Hakkawine.DatabaseSeeder
alias Hakkawine.System.Setting

settings_data = [
  # Site
  %{section: "site", key: "site_name", value: "Hakkawine", description: "Website display name"},
  %{section: "site", key: "site_description", value: "Fast and secure network services", description: "Website default SEO meta description"},
  %{section: "site", key: "site_url", value: "https://hakkawine.dev", description: "Primary domain URL for generating absolute links and callbacks"},
  %{section: "site", key: "logo_url", value: "https://hakkawine.dev/assets/logo.png", description: "Site header logo URL"},
  %{section: "site", key: "favicon_url", value: "https://hakkawine.dev/assets/favicon.ico", description: "Site browser tab icon URL"},
  %{section: "site", key: "tos_url", value: "https://hakkawine.dev/tos", description: "Terms of service URL"},

  # Security
  %{section: "security", key: "admin_path", value: "a8k9m2x1", description: "Secure random path for admin access"},
  %{section: "security", key: "admin_login_notify", value: true, description: "Send email notification to admin upon successful admin login"},
  %{section: "security", key: "user_ip_limit", value: 0, description: "Max concurrent IP limit per user account"},

  # i18n
  %{section: "i18n", key: "default_language", value: "en", description: "Default fallback language when user locale is not supported"},
  %{section: "i18n", key: "supported_languages", value: ["en", "zh-Hans", "zh-Hant"], description: "List of active languages enabled in the system selector"},

  # Currency
  %{section: "currency", key: "code", value: "USD", description: "Primary billing currency code (ISO 4217, e.g. USD, CNY, EUR)"},
  %{section: "currency", key: "symbol", value: "$", description: "Primary billing currency symbol displayed on frontend"},
  %{section: "currency", key: "stripe_exchange_rate", value: 1.0, description: "Exchange rate multiplier for Stripe payment gateway conversion"},

  # Email
  %{section: "email", key: "smtp_host", value: "smtp.mailgun.org", description: "SMTP server host"},
  %{section: "email", key: "smtp_port", value: 465, description: "SMTP server port"},
  %{section: "email", key: "smtp_encryption", value: "ssl", description: "Encryption method: ssl, tls, or none"},
  %{section: "email", key: "smtp_username", value: "postmaster@mg.hakkawine.dev", description: "SMTP auth username"},
  %{section: "email", key: "smtp_password", value: "your_secret_smtp_password", description: "SMTP auth password"},
  %{section: "email", key: "from_address", value: "noreply@hakkawine.dev", description: "Sender email address"},
  %{section: "email", key: "from_name", value: "Hakkawine", description: "Sender name displayed in user inbox"},

  # Registration
  %{section: "registration", key: "enable_register", value: true, description: "Toggle whether new user registration is open"},
  %{section: "registration", key: "email_verify_required", value: true, description: "Force email verification code check upon registration"},
  %{section: "registration", key: "email_whitelist_domains", value: [], description: "Allowed email domain whitelist"},
  %{section: "registration", key: "stop_register_on_ip_limit", value: false, description: "Restrict multi-account registration under the same IP address"},

  # Invite
  %{section: "invite", key: "invite_only", value: false, description: "Require invite code to register"},
  %{section: "invite", key: "default_commission_rate", value: 0.15, description: "Default commission percentage for inviter"},
  %{section: "invite", key: "withdrawal_min_amount", value: 10.0, description: "Minimum commission threshold required to request withdrawal"},

  # Telegram
  %{section: "telegram", key: "telegram_bot_enable", value: false, description: "Toggle Telegram Bot service"},
  %{section: "telegram", key: "telegram_bot_token", value: "", description: "Telegram Bot API Token for user binding and notification alerts"},
  %{section: "telegram", key: "telegram_bot_username", value: "", description: "Telegram Bot handle for quick user redirection"},
]

DatabaseSeeder.seed(
  Setting,
  :key,
  settings_data,
  update_fields: [:section, :value, :description]
)
