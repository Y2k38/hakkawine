CREATE TABLE user_audit_actions (
    code varchar(50) PRIMARY KEY,
    domain VARCHAR(20) NOT NULL,
    category varchar(50) NOT NULL,
    description text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT NOW()
);

INSERT INTO
    user_audit_actions (code, category, description)
VALUES
    ('user_register', 'user', 'auth', 'User registered a new account'),
    ('user_login_success', 'user', 'auth', 'User logged in via Web'),
    ('user_login_failed', 'user', 'auth', 'User failed to log in via Web'),
    ('email_verify_success', 'user', 'auth', 'User completed email verification'),
    ('pwd_update', 'user', 'security', 'User updated password in settings'),
    ('pwd_reset_request', 'user', 'security', 'User requested password reset link/code'),
    ('pwd_reset_success', 'user', 'security', 'User completed password reset'),
    ('email_update', 'user', 'security', 'User changed registered email address'),
    ('two_factor_enable', 'user', 'security', 'User enabled 2FA authentication'),
    ('two_factor_disable', 'user', 'security', 'User disabled 2FA authentication'),
    ('telegram_bind', 'user', 'security', 'User bound Telegram account'),
    ('telegram_unbind', 'user', 'security', 'User unbound Telegram account'),
    ('balance_recharge', 'user', 'financial', 'User balance recharged via payment gateway'),
    ('commission_transfer', 'user', 'financial', 'User transferred affiliate commission to balance'),
    ('withdraw_request', 'user', 'financial', 'User submitted commission withdrawal request'),
    ('subscribe_token_reset', 'user', 'account', 'User reset subscription URL token'),
    ('admin_user_suspend', 'admin', 'account', 'Admin suspended or banned a user account'),
    ('admin_user_unsuspend', 'admin', 'account', 'Admin unbanned a user account'),
    ('admin_user_role_update', 'admin', 'account', 'Admin modified a user role (e.g. staff/system_admin)'),
    ('admin_balance_adjust', 'admin', 'financial', 'Admin manually adjusted user balance'),
    ('admin_order_mark_paid', 'admin', 'financial', 'Admin manually marked order as paid'),
    ('admin_order_cancel', 'admin', 'financial', 'Admin forcibly cancelled an order'),
    ('admin_node_create', 'admin', 'system', 'Admin created a new proxy node'),
    ('admin_node_update', 'admin', 'system', 'Admin updated proxy node settings'),
    ('admin_node_delete', 'admin', 'system', 'Admin deleted a proxy node'),
    ('admin_config_update', 'admin', 'system', 'Admin updated global system settings');

CREATE TABLE user_audit_logs (
    user_id bigint NOT NULL,
    action_code varchar(50) NOT NULL,
    ip_address inet,
    user_agent text,
    metadata jsonb DEFAULT '{}',
    created_at timestamptz NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ual_user_time ON user_audit_logs (user_id, created_at DESC);

CREATE INDEX idx_ual_action_time ON user_audit_logs (action_code, created_at DESC);

CREATE INDEX idx_ual_ip_time ON user_audit_logs (ip_address, created_at DESC) WHERE ip_address IS NOT NULL;

CREATE TABLE admin_audit_logs (
    operator_id bigint NOT NULL,
    action_code varchar(50) NOT NULL,
    target_type varchar(50),
    target_id bigint,
    ip_address inet,
    user_agent text,
    metadata jsonb DEFAULT '{}',
    created_at timestamptz NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_aal_operator_time ON admin_audit_logs (operator_id, created_at DESC);

CREATE INDEX idx_aal_target ON admin_audit_logs (target_type, target_id) WHERE target_id IS NOT NULL;

CREATE INDEX idx_aal_action_time ON admin_audit_logs (action_code, created_at DESC);