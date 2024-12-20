DELIMITER //
CREATE PROCEDURE complete_job(
    IN p_booking_id INT,
    IN p_actual_duration_minutes INT,
    IN p_student_rating INT,
    IN p_student_review TEXT,
    IN p_tutor_notes TEXT,
    OUT p_status_msg VARCHAR(255)
)
BEGIN
    DECLARE v_job_id INT;
    DECLARE v_tutor_id INT;
    DECLARE v_subject VARCHAR(100);
    DECLARE v_description TEXT;
    DECLARE v_final_rate DECIMAL(10,2);
    DECLARE v_required_education_level VARCHAR(100);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_status_msg = 'Error: Failed to complete job';
        ROLLBACK;
    END;

    -- Get booking details
    SELECT bj.job_id, bj.tutor_id, j.subject, j.description, j.rate_per_hour, j.required_education_level
    INTO v_job_id, v_tutor_id, v_subject, v_description, v_final_rate, v_required_education_level
    FROM booked_jobs bj
    JOIN jobs j ON bj.job_id = j.job_id
    WHERE bj.booking_id = p_booking_id AND bj.booking_status = 'confirmed';

    -- Validate booking exists and is confirmed
    IF v_job_id IS NULL THEN
        SET p_status_msg = 'Error: Invalid booking or already completed';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid booking';
    END IF;

    -- Validate rating
    IF p_student_rating NOT BETWEEN 1 AND 5 THEN
        SET p_status_msg = 'Error: Invalid rating (must be between 1 and 5)';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid rating';
    END IF;

    START TRANSACTION;
        -- Insert into past_jobs
        INSERT INTO past_jobs (
            tutor_id,
            subject,
            description,
            actual_duration_minutes,
            final_rate,
            completion_status,
            student_rating,
            student_review,
            tutor_notes,
            education_level,
            completion_date
        ) VALUES (
            v_tutor_id,
            v_subject,
            v_description,
            p_actual_duration_minutes,
            v_final_rate,
            'completed',
            p_student_rating,
            p_student_review,
            p_tutor_notes,
            v_required_education_level,
            NOW()
        );

        -- Update booking status
        UPDATE booked_jobs 
        SET 
            booking_status = 'completed',
            completion_feedback = p_student_review,
            rating = p_student_rating
        WHERE booking_id = p_booking_id;

        -- Update job status
        UPDATE jobs 
        SET status = 'completed' 
        WHERE job_id = v_job_id;
        
        SET p_status_msg = 'Success: Job completed successfully';
    COMMIT;
END //

DELIMITER ;