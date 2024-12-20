DROP DATABASE IF EXISTS studymate;
CREATE DATABASE studymate;
USE studymate;

-- 1. Users table (base table with no foreign key dependencies)
CREATE TABLE `users` (
  `student_id` int NOT NULL AUTO_INCREMENT,
  `full_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `verified` tinyint(1) DEFAULT '0',
  `role` varchar(50) NOT NULL DEFAULT 'student',
  `profile_picture` mediumblob,
  PRIMARY KEY (`student_id`),
  UNIQUE KEY `email` (`email`),
  KEY `email_idx` (`email`)
);

-- 2. Tutors table (depends on users)
CREATE TABLE `tutors` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `verification_status` enum('pending','approved','rejected') DEFAULT 'pending',
  `education_level` varchar(100) DEFAULT NULL,
  `years_of_experience` int DEFAULT NULL,
  `hourly_rate` decimal(10,2) DEFAULT NULL,
  `subjects_taught` text,
  `availability` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `idx_verification` (`verification_status`),
  KEY `idx_subjects` (`subjects_taught`(768)),
  CONSTRAINT `tutors_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`student_id`) ON DELETE CASCADE
);

-- 3. Jobs table (depends on tutors)
CREATE TABLE `jobs` (
  `job_id` int NOT NULL AUTO_INCREMENT,
  `tutor_id` int NOT NULL,
  `subject` varchar(100) NOT NULL,
  `description` text,
  `duration_minutes` int NOT NULL,
  `rate_per_hour` decimal(10,2) NOT NULL,
  `status` enum('open','assigned','completed','cancelled') DEFAULT 'open',
  `required_education_level` varchar(100) DEFAULT NULL,
  `preferred_teaching_style` text,
  `special_requirements` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`job_id`),
  KEY `idx_tutor` (`tutor_id`),
  KEY `idx_status` (`status`),
  KEY `idx_subject` (`subject`),
  CONSTRAINT `jobs_ibfk_1` FOREIGN KEY (`tutor_id`) REFERENCES `tutors` (`id`) ON DELETE CASCADE
);

-- 4. Booked Jobs table (depends on jobs, tutors, and users)
CREATE TABLE `booked_jobs` (
  `booking_id` int NOT NULL AUTO_INCREMENT,
  `job_id` int NOT NULL,
  `tutor_id` int NOT NULL,
  `student_id` int NOT NULL,
  `scheduled_start_date` datetime NOT NULL,
  `scheduled_end_date` datetime NOT NULL,
  `booking_status` enum('confirmed','in_progress','completed','cancelled') DEFAULT 'confirmed',
  `payment_status` enum('pending','paid','refunded') DEFAULT 'pending',
  `final_amount` decimal(10,2) NOT NULL,
  `meeting_link` varchar(255) DEFAULT NULL,
  `student_notes` text,
  `tutor_notes` text,
  `completion_feedback` text,
  `rating` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`booking_id`),
  UNIQUE KEY `unique_active_job` (`job_id`,`booking_status`),
  KEY `idx_tutor_date` (`tutor_id`,`scheduled_start_date`),
  KEY `idx_student_date` (`student_id`,`scheduled_start_date`),
  KEY `idx_booking_status` (`booking_status`),
  KEY `idx_payment_status` (`payment_status`),
  CONSTRAINT `booked_jobs_job_fk` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`job_id`) ON DELETE RESTRICT,
  CONSTRAINT `booked_jobs_student_fk` FOREIGN KEY (`student_id`) REFERENCES `users` (`student_id`) ON DELETE RESTRICT,
  CONSTRAINT `booked_jobs_tutor_fk` FOREIGN KEY (`tutor_id`) REFERENCES `tutors` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `booked_jobs_chk_1` CHECK (((`rating` >= 1) and (`rating` <= 5))),
  CONSTRAINT `check_scheduled_dates` CHECK ((`scheduled_end_date` > `scheduled_start_date`))
);

-- 5. Course ID table (no dependencies)
CREATE TABLE `course_id` (
  `id` int NOT NULL AUTO_INCREMENT,
  `course_code` varchar(10) NOT NULL,
  `course_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
);

-- 6. Faculty table (no dependencies)
CREATE TABLE `faculty` (
  `faculty_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) DEFAULT NULL,
  `middle_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`faculty_id`)
);

-- 7. Notes table (depends on users)
CREATE TABLE `notes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `course_code` varchar(50) NOT NULL,
  `course_title` varchar(255) NOT NULL,
  `professor` varchar(255) NOT NULL,
  `uploader_name` varchar(255) NOT NULL,
  `description` text,
  `price` decimal(10,2) NOT NULL,
  `semester` varchar(50) NOT NULL,
  `pdf_data` longblob NOT NULL,
  `pdf_name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `uploader_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_uploader` (`uploader_id`),
  CONSTRAINT `fk_uploader` FOREIGN KEY (`uploader_id`) REFERENCES `users` (`student_id`)
);

-- 8. Past Jobs table (depends on tutors)
CREATE TABLE `past_jobs` (
  `past_job_id` int NOT NULL AUTO_INCREMENT,
  `tutor_id` int NOT NULL,
  `subject` varchar(100) NOT NULL,
  `description` text,
  `actual_duration_minutes` int NOT NULL,
  `final_rate` decimal(10,2) NOT NULL,
  `completion_status` enum('completed','cancelled','no_show') NOT NULL,
  `student_rating` int DEFAULT NULL,
  `student_review` text,
  `tutor_notes` text,
  `education_level` varchar(100) DEFAULT NULL,
  `completion_date` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`past_job_id`),
  KEY `idx_tutor` (`tutor_id`),
  KEY `idx_subject` (`subject`),
  KEY `idx_completion_status` (`completion_status`),
  KEY `idx_completion_date` (`completion_date`),
  CONSTRAINT `past_jobs_ibfk_1` FOREIGN KEY (`tutor_id`) REFERENCES `tutors` (`id`) ON DELETE CASCADE
);

-- 9. Profiles table (depends on users)
CREATE TABLE `profiles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `avatar_url` varchar(255) DEFAULT NULL,
  `bio` text,
  `phone_number` varchar(20) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `time_zone` varchar(50) DEFAULT NULL,
  `languages_spoken` varchar(255) DEFAULT NULL,
  `social_media_links` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `idx_location` (`location`),
  CONSTRAINT `profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`student_id`) ON DELETE CASCADE
);

-- 10. Verification Tokens table (depends on users)
CREATE TABLE `verification_tokens` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `token` varchar(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_token` (`token`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `verification_tokens_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `users` (`student_id`)
);