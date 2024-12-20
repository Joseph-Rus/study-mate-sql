DELIMITER //

CREATE PROCEDURE add_user_as_tutor(
    IN p_user_id INT,
    IN p_education_level VARCHAR(100),
    IN p_years_experience INT,
    IN p_hourly_rate DECIMAL(10,2),
    IN p_subjects_taught TEXT,
    IN p_availability JSON
)
BEGIN
    -- Declare variables for error handling
    DECLARE user_exists INT;
    
    -- Check if user exists and is not already a tutor
    SELECT COUNT(*) INTO user_exists 
    FROM users 
    WHERE student_id = p_user_id 
    AND role != 'tutor';
    
    -- Start transaction to ensure both operations complete or none
    START TRANSACTION;
    
    IF user_exists > 0 THEN
        -- Insert into tutors table
        INSERT INTO tutors (
            user_id,
            education_level,
            years_of_experience,
            hourly_rate,
            subjects_taught,
            availability
        ) VALUES (
            p_user_id,
            p_education_level,
            p_years_experience,
            p_hourly_rate,
            p_subjects_taught,
            p_availability
        );
        
        -- Update user role to tutor
        UPDATE users 
        SET role = 'tutor' 
        WHERE student_id = p_user_id;
        
        -- If we get here, commit the transaction
        COMMIT;
        
        SELECT 'User successfully added as tutor' AS message;
    ELSE
        -- Roll back if user doesn't exist or is already a tutor
        ROLLBACK;
        SELECT 'Error: User not found or already a tutor' AS message;
    END IF;
    
END //

DELIMITER ;