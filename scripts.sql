CREATE DATABASE npgauth;

------------------------------------------------------------------------------------------
-- USERS
------------------------------------------------------------------------------------------
CREATE TABLE users
(
    id                     SERIAL PRIMARY KEY,
    access_failed_count    INT          NOT NULL DEFAULT 0,
    concurrency_stamp      VARCHAR(36)  NOT NULL,
    email                  VARCHAR(160) NOT NULL,
    email_confirmed        BOOLEAN      NOT NULL DEFAULT FALSE,
    first_name             VARCHAR(80)  NOT NULL,
    last_name              VARCHAR(80)  NOT NULL,
    lockout_enabled        BOOLEAN      NOT NULL DEFAULT TRUE,
    lockout_end            TIMESTAMPTZ  NULL,
    normalized_email       VARCHAR(160) NOT NULL,
    normalized_username    VARCHAR(80)  NOT NULL,
    password_hash          VARCHAR(256) NOT NULL,
    phone_number           VARCHAR(30)  NULL,
    phone_number_confirmed BOOLEAN      NOT NULL DEFAULT FALSE,
    security_stamp         VARCHAR(36)  NOT NULL,
    two_factor_enabled     BOOLEAN      NOT NULL DEFAULT FALSE,
    username               VARCHAR(80)  NOT NULL
);

CREATE UNIQUE INDEX ix_users_normalized_email ON users (normalized_email);
CREATE UNIQUE INDEX ix_users_normalized_username ON users (normalized_username);

------------------------------------------------------------------------------------------
-- USER CLAIMS
------------------------------------------------------------------------------------------
CREATE TABLE user_claims
(
    id          SERIAL PRIMARY KEY,
    claim_type  VARCHAR(256)  NOT NULL,
    claim_value VARCHAR(1024) NULL,
    user_id     INTEGER       NOT NULL,
    CONSTRAINT fk_user_claims_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE INDEX ix_user_claims_user_id ON user_claims (user_id);
CREATE INDEX ix_user_claims_claim_type ON user_claims (claim_type, user_id);

------------------------------------------------------------------------------------------
-- ROLES
------------------------------------------------------------------------------------------
CREATE TABLE roles
(
    id                SERIAL PRIMARY KEY,
    concurrency_stamp VARCHAR(36) NOT NULL,
    name              VARCHAR(80) NOT NULL,
    normalized_name   VARCHAR(80) NOT NULL
);

CREATE UNIQUE INDEX ix_roles_normalized_name ON roles (normalized_name);

------------------------------------------------------------------------------------------
-- ROLE CLAIMS
------------------------------------------------------------------------------------------
CREATE TABLE role_claims
(
    id          SERIAL PRIMARY KEY,
    claim_type  VARCHAR(256)  NOT NULL,
    claim_value VARCHAR(1024) NULL,
    role_id     INTEGER       NOT NULL,
    CONSTRAINT fk_role_claims_role FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE
);

CREATE INDEX ix_roles_claims_user_id ON role_claims (role_id);
CREATE INDEX ix_roles_claims_claim_type ON role_claims (claim_type, role_id);

------------------------------------------------------------------------------------------
-- USER ROLES
------------------------------------------------------------------------------------------
CREATE TABLE user_roles
(
    user_id INTEGER NOT NULL,
    role_id INTEGER NOT NULL,
    CONSTRAINT pk_user_roles PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE
);

------------------------------------------------------------------------------------------
-- USER TOKENS
------------------------------------------------------------------------------------------
CREATE TABLE user_tokens
(
    user_id        INTEGER      NOT NULL,
    login_provider VARCHAR(80)  NOT NULL,
    name           VARCHAR(80)  NOT NULL,
    value          VARCHAR(512) NULL,
    CONSTRAINT pk_user_tokens PRIMARY KEY (user_id, login_provider, name),
    CONSTRAINT fk_user_tokens_users FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE INDEX ix_user_tokens_user_id ON user_tokens (user_id);
CREATE INDEX ix_user_tokens_login_provider ON user_tokens (login_provider);

------------------------------------------------------------------------------------------
-- USER LOGINS
------------------------------------------------------------------------------------------
CREATE TABLE user_logins
(
    login_provider        VARCHAR(80) NOT NULL,
    provider_key          VARCHAR(80) NOT NULL,
    provider_display_name VARCHAR(80) NULL,
    user_id               INTEGER     NOT NULL,
    CONSTRAINT pk_user_logins PRIMARY KEY (login_provider, provider_key),
    CONSTRAINT fk_user_logins_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE INDEX ix_user_logins_user_id ON user_logins (user_id);