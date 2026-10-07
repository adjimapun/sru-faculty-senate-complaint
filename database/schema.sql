CREATE DATABASE IF NOT EXISTS sru_complaint CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sru_complaint;

CREATE TABLE complaint_categories (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description VARCHAR(500) NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_category_name (name)
) ENGINE=InnoDB;

CREATE TABLE complaints (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    case_no VARCHAR(40) NOT NULL,
    category_id BIGINT UNSIGNED NOT NULL,
    citizen_id_enc TEXT NOT NULL,
    full_name_enc TEXT NOT NULL,
    phone_enc TEXT NOT NULL,
    email_enc TEXT NOT NULL,
    details MEDIUMTEXT NOT NULL,
    status ENUM('new','in_review','forwarded','resolved','rejected') NOT NULL DEFAULT 'new',
    submitted_ip_hash CHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_case_no (case_no),
    KEY idx_complaints_category (category_id),
    KEY idx_complaints_status_created (status, created_at),
    CONSTRAINT fk_complaints_category FOREIGN KEY (category_id) REFERENCES complaint_categories(id)
) ENGINE=InnoDB;

CREATE TABLE category_recipients (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(190) NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_category_email (category_id, email),
    CONSTRAINT fk_recipients_category FOREIGN KEY (category_id) REFERENCES complaint_categories(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(80) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(190) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('super_admin','admin') NOT NULL DEFAULT 'admin',
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_users_username (username),
    UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB;

CREATE TABLE login_attempts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username_hash CHAR(64) NOT NULL,
    ip_hash CHAR(64) NOT NULL,
    attempted_at DATETIME NOT NULL,
    KEY idx_login_attempts_time (attempted_at)
) ENGINE=InnoDB;


CREATE TABLE submission_attempts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ip_hash CHAR(64) NOT NULL,
    attempted_at DATETIME NOT NULL,
    KEY idx_submission_attempts_ip_time (ip_hash, attempted_at)
) ENGINE=InnoDB;

CREATE TABLE audit_logs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(80) NULL,
    entity_id BIGINT UNSIGNED NULL,
    ip_hash CHAR(64) NOT NULL,
    metadata_json JSON NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_audit_created (created_at),
    KEY idx_audit_user (user_id),
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

INSERT INTO complaint_categories (name, description) VALUES
('ด้านการบริหารและธรรมาภิบาล', 'ข้อร้องเรียนเกี่ยวกับการบริหารจัดการและธรรมาภิบาล'),
('ด้านบุคลากรและสวัสดิการ', 'ข้อร้องเรียนเกี่ยวกับบุคลากร สิทธิ และสวัสดิการ'),
('ด้านวิชาการ', 'ข้อร้องเรียนเกี่ยวกับการเรียนการสอนและวิชาการ'),
('อื่น ๆ', 'เรื่องร้องเรียนอื่นที่ไม่อยู่ในหมวดข้างต้น');
