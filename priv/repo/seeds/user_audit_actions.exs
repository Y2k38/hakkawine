alias Hakkawine.DatabaseSeeder
alias Hakkawine.Audits.UserAuditAction

actions_data = [
  # User Authentication & Security
  %{code: "user_register",          domain: "user",  category: "auth",      description: "User registered a new account"},
  %{code: "user_login_success",     domain: "user",  category: "auth",      description: "User logged in via Web"},
  %{code: "user_login_failed",      domain: "user",  category: "auth",      description: "User failed to log in via Web"},
  %{code: "email_verify_success",   domain: "user",  category: "auth",      description: "User completed email verification"},
  %{code: "pwd_update",             domain: "user",  category: "security",  description: "User updated password in settings"},
  %{code: "pwd_reset_request",      domain: "user",  category: "security",  description: "User requested password reset link/code"},
  %{code: "pwd_reset_success",      domain: "user",  category: "security",  description: "User completed password reset"},
  %{code: "email_update",           domain: "user",  category: "security",  description: "User changed registered email address"},
  %{code: "two_factor_enable",      domain: "user",  category: "security",  description: "User enabled 2FA authentication"},
  %{code: "two_factor_disable",     domain: "user",  category: "security",  description: "User disabled 2FA authentication"},
  %{code: "telegram_bind",          domain: "user",  category: "security",  description: "User bound Telegram account"},
  %{code: "telegram_unbind",        domain: "user",  category: "security",  description: "User unbound Telegram account"},

  # User Account & Financial Operations
  %{code: "balance_recharge",       domain: "user",  category: "financial", description: "User balance recharged via payment gateway"},
  %{code: "commission_transfer",    domain: "user",  category: "financial", description: "User transferred affiliate commission to balance"},
  %{code: "withdraw_request",       domain: "user",  category: "financial", description: "User submitted commission withdrawal request"},
  %{code: "subscribe_token_reset",  domain: "user",  category: "account",   description: "User reset subscription URL token"},

  # Admin Management & Interventions
  %{code: "admin_user_suspend",     domain: "admin", category: "account",   description: "Admin suspended or banned a user account"},
  %{code: "admin_user_unsuspend",   domain: "admin", category: "account",   description: "Admin unbanned a user account"},
  %{code: "admin_user_role_update", domain: "admin", category: "account",   description: "Admin modified a user role"},
  %{code: "admin_balance_adjust",   domain: "admin", category: "financial", description: "Admin manually adjusted user balance"},
  %{code: "admin_order_mark_paid",  domain: "admin", category: "financial", description: "Admin manually marked order as paid"},
  %{code: "admin_order_cancel",     domain: "admin", category: "financial", description: "Admin forcibly cancelled an order"},
  %{code: "admin_node_create",      domain: "admin", category: "system",    description: "Admin created a new proxy node"},
  %{code: "admin_node_update",      domain: "admin", category: "system",    description: "Admin updated proxy node settings"},
  %{code: "admin_node_delete",      domain: "admin", category: "system",    description: "Admin deleted a proxy node"},
  %{code: "admin_config_update",    domain: "admin", category: "system",    description: "Admin updated global system settings"}
]

DatabaseSeeder.seed(
  UserAuditAction,
  :code,
  actions_data,
  update_fields: [:domain, :category, :description]
)
