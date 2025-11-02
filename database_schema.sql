-- =====================================================
-- RWA - Database Schema for Multimedia Management App
-- =====================================================
-- This schema can be opened and visualized in MySQL Workbench
-- Use File -> Open Model -> Reverse Engineer to create ER diagram
-- =====================================================

-- Drop existing tables if they exist (in reverse order of dependencies)
DROP TABLE IF EXISTS `user_favorites`;
DROP TABLE IF EXISTS `ratings`;
DROP TABLE IF EXISTS `reviews`;
DROP TABLE IF EXISTS `media_genres`;
DROP TABLE IF EXISTS `media_actors`;
DROP TABLE IF EXISTS `genres`;
DROP TABLE IF EXISTS `actors`;
DROP TABLE IF EXISTS `media_items`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `roles`;

-- =====================================================
-- Table: roles
-- Description: Defines user roles with hierarchical levels
-- =====================================================
CREATE TABLE `roles` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL UNIQUE,
  `level` INT NOT NULL COMMENT '1=guest, 2=user, 3=moderator, 4=admin',
  `description` VARCHAR(255) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_level` (`level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: users
-- Description: Stores user account information
-- =====================================================
CREATE TABLE `users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `first_name` VARCHAR(50) NULL,
  `last_name` VARCHAR(50) NULL,
  `role_id` INT NOT NULL DEFAULT 2 COMMENT 'Foreign key to roles table',
  `is_active` BOOLEAN DEFAULT TRUE,
  `email_verified` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_login` TIMESTAMP NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_username` (`username`),
  INDEX `idx_email` (`email`),
  INDEX `idx_role_id` (`role_id`),
  CONSTRAINT `fk_users_role`
    FOREIGN KEY (`role_id`)
    REFERENCES `roles` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: media_items
-- Description: Stores multimedia content (movies, TV shows, music, etc.)
-- =====================================================
CREATE TABLE `media_items` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(255) NOT NULL,
  `original_title` VARCHAR(255) NULL,
  `media_type` ENUM('movie', 'tv_series', 'music', 'podcast', 'book', 'game', 'other') NOT NULL,
  `description` TEXT NULL,
  `release_date` DATE NULL,
  `runtime` INT NULL COMMENT 'Runtime in minutes',
  `poster_url` VARCHAR(500) NULL,
  `backdrop_url` VARCHAR(500) NULL,
  `trailer_url` VARCHAR(500) NULL,
  `tmdb_id` INT NULL COMMENT 'TMDB API ID if from external service',
  `imdb_id` VARCHAR(20) NULL,
  `source` ENUM('tmdb', 'internal') NOT NULL DEFAULT 'internal',
  `language` VARCHAR(10) NULL,
  `country` VARCHAR(10) NULL,
  `budget` DECIMAL(15,2) NULL,
  `revenue` DECIMAL(15,2) NULL,
  `status` ENUM('released', 'upcoming', 'in_production', 'cancelled') DEFAULT 'released',
  `popularity` DECIMAL(10,3) DEFAULT 0.0,
  `vote_average` DECIMAL(3,1) DEFAULT 0.0,
  `vote_count` INT DEFAULT 0,
  `added_by_user_id` INT NULL COMMENT 'User who added this content',
  `is_approved` BOOLEAN DEFAULT FALSE COMMENT 'For moderation',
  `approved_by_user_id` INT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_title` (`title`),
  INDEX `idx_media_type` (`media_type`),
  INDEX `idx_tmdb_id` (`tmdb_id`),
  INDEX `idx_source` (`source`),
  INDEX `idx_release_date` (`release_date`),
  INDEX `idx_popularity` (`popularity`),
  INDEX `idx_is_approved` (`is_approved`),
  CONSTRAINT `fk_media_added_by`
    FOREIGN KEY (`added_by_user_id`)
    REFERENCES `users` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `fk_media_approved_by`
    FOREIGN KEY (`approved_by_user_id`)
    REFERENCES `users` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: actors
-- Description: Stores actor/cast information
-- =====================================================
CREATE TABLE `actors` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `birth_date` DATE NULL,
  `biography` TEXT NULL,
  `profile_url` VARCHAR(500) NULL,
  `tmdb_id` INT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_name` (`name`),
  INDEX `idx_tmdb_id` (`tmdb_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: genres
-- Description: Stores genre categories
-- =====================================================
CREATE TABLE `genres` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL UNIQUE,
  `tmdb_id` INT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: media_actors
-- Description: Many-to-many relationship between media items and actors
-- =====================================================
CREATE TABLE `media_actors` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `media_id` INT NOT NULL,
  `actor_id` INT NOT NULL,
  `character_name` VARCHAR(100) NULL,
  `cast_order` INT NULL COMMENT 'Order of appearance in credits',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `unique_media_actor` (`media_id`, `actor_id`),
  INDEX `idx_media_id` (`media_id`),
  INDEX `idx_actor_id` (`actor_id`),
  CONSTRAINT `fk_media_actors_media`
    FOREIGN KEY (`media_id`)
    REFERENCES `media_items` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_media_actors_actor`
    FOREIGN KEY (`actor_id`)
    REFERENCES `actors` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: media_genres
-- Description: Many-to-many relationship between media items and genres
-- =====================================================
CREATE TABLE `media_genres` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `media_id` INT NOT NULL,
  `genre_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `unique_media_genre` (`media_id`, `genre_id`),
  INDEX `idx_media_id` (`media_id`),
  INDEX `idx_genre_id` (`genre_id`),
  CONSTRAINT `fk_media_genres_media`
    FOREIGN KEY (`media_id`)
    REFERENCES `media_items` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_media_genres_genre`
    FOREIGN KEY (`genre_id`)
    REFERENCES `genres` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: reviews
-- Description: User reviews for media items
-- =====================================================
CREATE TABLE `reviews` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `media_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `title` VARCHAR(255) NULL,
  `content` TEXT NOT NULL,
  `is_approved` BOOLEAN DEFAULT FALSE,
  `approved_by_user_id` INT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_media_id` (`media_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_created_at` (`created_at`),
  CONSTRAINT `fk_reviews_media`
    FOREIGN KEY (`media_id`)
    REFERENCES `media_items` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_reviews_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_reviews_approved_by`
    FOREIGN KEY (`approved_by_user_id`)
    REFERENCES `users` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: ratings
-- Description: User ratings for media items
-- =====================================================
CREATE TABLE `ratings` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `media_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `rating` DECIMAL(2,1) NOT NULL COMMENT 'Rating from 0.0 to 10.0',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `unique_user_media_rating` (`user_id`, `media_id`),
  INDEX `idx_media_id` (`media_id`),
  INDEX `idx_user_id` (`user_id`),
  CONSTRAINT `fk_ratings_media`
    FOREIGN KEY (`media_id`)
    REFERENCES `media_items` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_ratings_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `chk_rating_range`
    CHECK (`rating` >= 0.0 AND `rating` <= 10.0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: user_favorites
-- Description: User's favorite media items
-- =====================================================
CREATE TABLE `user_favorites` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `media_id` INT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `unique_user_favorite` (`user_id`, `media_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_media_id` (`media_id`),
  CONSTRAINT `fk_favorites_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_favorites_media`
    FOREIGN KEY (`media_id`)
    REFERENCES `media_items` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Insert Initial Data
-- =====================================================

-- Insert default roles (hierarchical: guest < user < moderator < admin)
INSERT INTO `roles` (`name`, `level`, `description`) VALUES
('guest', 1, 'Guest user with limited access'),
('user', 2, 'Regular registered user'),
('moderator', 3, 'Moderator with content management permissions'),
('admin', 4, 'Administrator with full system access');

-- Insert sample genres
INSERT INTO `genres` (`name`, `tmdb_id`) VALUES
('Action', 28),
('Adventure', 12),
('Animation', 16),
('Comedy', 35),
('Crime', 80),
('Documentary', 99),
('Drama', 18),
('Family', 10751),
('Fantasy', 14),
('History', 36),
('Horror', 27),
('Music', 10402),
('Mystery', 9648),
('Romance', 10749),
('Science Fiction', 878),
('TV Movie', 10770),
('Thriller', 53),
('War', 10752),
('Western', 37);

-- Create a default admin user (password should be changed)
-- Password: 'admin123' hashed with bcrypt (this is just a placeholder, use proper hashing)
INSERT INTO `users` (`username`, `email`, `password_hash`, `first_name`, `last_name`, `role_id`, `is_active`, `email_verified`) VALUES
('admin', 'admin@example.com', '$2b$10$rWjK7bCZxJJz.vxGZ9aYeOZpJxJXJXJXJXJXJXJXJXJXJXJXJXJ', 'Admin', 'User', 4, TRUE, TRUE);

-- =====================================================
-- Views for easier querying
-- =====================================================

-- View: User details with role information
CREATE OR REPLACE VIEW `v_users_with_roles` AS
SELECT 
  u.id,
  u.username,
  u.email,
  u.first_name,
  u.last_name,
  r.name AS role_name,
  r.level AS role_level,
  u.is_active,
  u.email_verified,
  u.created_at,
  u.last_login
FROM users u
INNER JOIN roles r ON u.role_id = r.id;

-- View: Media items with aggregated ratings and genre information
CREATE OR REPLACE VIEW `v_media_with_stats` AS
SELECT 
  m.id,
  m.title,
  m.media_type,
  m.description,
  m.release_date,
  m.poster_url,
  m.source,
  m.is_approved,
  m.popularity,
  COALESCE(AVG(rat.rating), 0) AS avg_user_rating,
  COUNT(DISTINCT rat.id) AS rating_count,
  COUNT(DISTINCT rev.id) AS review_count,
  COUNT(DISTINCT fav.id) AS favorite_count,
  GROUP_CONCAT(DISTINCT g.name ORDER BY g.name SEPARATOR ', ') AS genres,
  m.created_at
FROM media_items m
LEFT JOIN ratings rat ON m.id = rat.media_id
LEFT JOIN reviews rev ON m.id = rev.media_id AND rev.is_approved = TRUE
LEFT JOIN user_favorites fav ON m.id = fav.media_id
LEFT JOIN media_genres mg ON m.id = mg.media_id
LEFT JOIN genres g ON mg.genre_id = g.id
GROUP BY m.id, m.title, m.media_type, m.description, m.release_date, 
         m.poster_url, m.source, m.is_approved, m.popularity, m.created_at;

-- =====================================================
-- Stored Procedures for Pagination
-- =====================================================

DELIMITER $$

-- Procedure: Get paginated media items
CREATE PROCEDURE `sp_get_paginated_media`(
  IN p_page INT,
  IN p_page_size INT,
  IN p_media_type VARCHAR(50),
  IN p_search_term VARCHAR(255),
  IN p_order_by VARCHAR(50)
)
BEGIN
  DECLARE v_offset INT;
  SET v_offset = (p_page - 1) * p_page_size;
  
  -- Determine sort order
  SET @order_clause = CASE p_order_by
    WHEN 'title_asc' THEN 'ORDER BY m.title ASC'
    WHEN 'title_desc' THEN 'ORDER BY m.title DESC'
    WHEN 'release_date_desc' THEN 'ORDER BY m.release_date DESC'
    WHEN 'release_date_asc' THEN 'ORDER BY m.release_date ASC'
    WHEN 'popularity_desc' THEN 'ORDER BY m.popularity DESC'
    WHEN 'rating_desc' THEN 'ORDER BY avg_user_rating DESC'
    ELSE 'ORDER BY m.created_at DESC'
  END;
  
  SELECT 
    m.id,
    m.title,
    m.media_type,
    m.description,
    m.release_date,
    m.poster_url,
    m.popularity,
    COALESCE(AVG(r.rating), 0) AS avg_user_rating,
    COUNT(DISTINCT r.id) AS rating_count
  FROM media_items m
  LEFT JOIN ratings r ON m.id = r.media_id
  WHERE 
    (p_media_type IS NULL OR m.media_type = p_media_type)
    AND (p_search_term IS NULL OR m.title LIKE CONCAT('%', p_search_term, '%'))
    AND m.is_approved = TRUE
  GROUP BY m.id, m.title, m.media_type, m.description, m.release_date, 
           m.poster_url, m.popularity
  ORDER BY m.created_at DESC
  LIMIT p_page_size OFFSET v_offset;
  
  -- Return total count for pagination
  SELECT COUNT(DISTINCT m.id) AS total_count
  FROM media_items m
  WHERE 
    (p_media_type IS NULL OR m.media_type = p_media_type)
    AND (p_search_term IS NULL OR m.title LIKE CONCAT('%', p_search_term, '%'))
    AND m.is_approved = TRUE;
END$$

-- Procedure: Get paginated users (admin only)
CREATE PROCEDURE `sp_get_paginated_users`(
  IN p_page INT,
  IN p_page_size INT,
  IN p_role_id INT,
  IN p_search_term VARCHAR(255)
)
BEGIN
  DECLARE v_offset INT;
  SET v_offset = (p_page - 1) * p_page_size;
  
  SELECT 
    u.id,
    u.username,
    u.email,
    u.first_name,
    u.last_name,
    r.name AS role_name,
    r.level AS role_level,
    u.is_active,
    u.created_at,
    u.last_login
  FROM users u
  INNER JOIN roles r ON u.role_id = r.id
  WHERE 
    (p_role_id IS NULL OR u.role_id = p_role_id)
    AND (p_search_term IS NULL OR 
         u.username LIKE CONCAT('%', p_search_term, '%') OR
         u.email LIKE CONCAT('%', p_search_term, '%') OR
         CONCAT(u.first_name, ' ', u.last_name) LIKE CONCAT('%', p_search_term, '%'))
  ORDER BY u.created_at DESC
  LIMIT p_page_size OFFSET v_offset;
  
  -- Return total count
  SELECT COUNT(*) AS total_count
  FROM users u
  WHERE 
    (p_role_id IS NULL OR u.role_id = p_role_id)
    AND (p_search_term IS NULL OR 
         u.username LIKE CONCAT('%', p_search_term, '%') OR
         u.email LIKE CONCAT('%', p_search_term, '%') OR
         CONCAT(u.first_name, ' ', u.last_name) LIKE CONCAT('%', p_search_term, '%'));
END$$

DELIMITER ;

-- =====================================================
-- End of Schema
-- =====================================================
