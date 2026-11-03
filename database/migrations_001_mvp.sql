-- =========================================================
-- AgroFarm MVP migration 001
-- Run ONCE on an existing database (phpMyAdmin > SQL, or:
--   mysql -u root farmproject < database/migrations_001_mvp.sql)
-- Safe to re-run.
-- =========================================================

-- Brute-force protection for login.php
CREATE TABLE IF NOT EXISTS `login_attempts` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ip` VARCHAR(45) NOT NULL,
  `attempted_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ip_time` (`ip`, `attempted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Password column must fit bcrypt/argon hashes (plain-text passwords are
-- upgraded to hashes automatically the next time each user logs in)
ALTER TABLE `users` MODIFY `password` VARCHAR(255) NOT NULL;
