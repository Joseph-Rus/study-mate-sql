DELIMITER //
CREATE PROCEDURE add_profile(
    IN p_user_id INT,
    IN p_avatar_url VARCHAR(255),
    IN p_bio TEXT,
    IN p_phone_number VARCHAR(20),
    IN p_location VARCHAR(255),
    IN p_time_zone VARCHAR(50),
    IN p_languages_spoken VARCHAR(255),
    IN p_social_media_links JSON,
    OUT p_status_msg VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_status_msg = 'Error: Failed to create profile';
        ROLLBACK;
    END;

    -- Validate user exists
    IF NOT EXISTS (SELECT 1 FROM users WHERE student_id = p_user_id) THEN
        SET p_status_msg = 'Error: User does not exist';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User does not exist';
    END IF;

    -- Check if profile already exists
    IF EXISTS (SELECT 1 FROM profiles WHERE user_id = p_user_id) THEN
        SET p_status_msg = 'Error: Profile already exists for this user';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Profile already exists';
    END IF;

    START TRANSACTION;
        INSERT INTO profiles (
            user_id,
            avatar_url,
            bio,
            phone_number,
            location,
            time_zone,
            languages_spoken,
            social_media_links
        ) VALUES (
            p_user_id,
            p_avatar_url,
            p_bio,
            p_phone_number,
            p_location,
            p_time_zone,
            p_languages_spoken,
            p_social_media_links
        );
        
        SET p_status_msg = 'Success: Profile created successfully';
    COMMIT;
END //