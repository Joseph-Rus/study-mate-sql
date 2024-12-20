DELIMITER //
CREATE PROCEDURE create_job(
    IN p_tutor_id INT,
    IN p_subject VARCHAR(100),
    IN p_description TEXT,
    IN p_duration_minutes INT,
    IN p_rate_per_hour DECIMAL(10,2),
    IN p_required_education_level VARCHAR(100),
    IN p_preferred_teaching_style TEXT,
    IN p_special_requirements TEXT,
    OUT p_job_id INT,
    OUT p_status_msg VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_status_msg = 'Error: Failed to create job';
        SET p_job_id = 0;
        ROLLBACK;
    END;

    -- Validate tutor exists and is approved
    IF NOT EXISTS (
        SELECT 1 FROM tutors 
        WHERE id = p_tutor_id 
        AND verification_status = 'approved'
    ) THEN
        SET p_status_msg = 'Error: Invalid or unapproved tutor';
        SET p_job_id = 0;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid or unapproved tutor';
    END IF;

    -- Validate duration and rate
    IF p_duration_minutes <= 0 OR p_rate_per_hour <= 0 THEN
        SET p_status_msg = 'Error: Invalid duration or rate';
        SET p_job_id = 0;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid duration or rate';
    END IF;

    START TRANSACTION;
        INSERT INTO jobs (
            tutor_id,
            subject,
            description,
            duration_minutes,
            rate_per_hour,
            status,
            required_education_level,
            preferred_teaching_style,
            special_requirements
        ) VALUES (
            p_tutor_id,
            p_subject,
            p_description,
            p_duration_minutes,
            p_rate_per_hour,
            'open',
            p_required_education_level,
            p_preferred_teaching_style,
            p_special_requirements
        );
        
        SET p_job_id = LAST_INSERT_ID();
        SET p_status_msg = 'Success: Job created successfully';
    COMMIT;
END //