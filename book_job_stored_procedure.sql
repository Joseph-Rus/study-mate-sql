DELIMITER //
CREATE PROCEDURE book_job(
    IN p_job_id INT,
    IN p_student_id INT,
    IN p_scheduled_start_date DATETIME,
    IN p_scheduled_end_date DATETIME,
    OUT p_booking_id INT,
    OUT p_status_msg VARCHAR(255)
)
BEGIN
    DECLARE v_tutor_id INT;
    DECLARE v_final_amount DECIMAL(10,2);
    DECLARE v_duration_minutes INT;
    DECLARE v_rate_per_hour DECIMAL(10,2);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_status_msg = 'Error: Failed to book job';
        SET p_booking_id = 0;
        ROLLBACK;
    END;

    -- Get job details
    SELECT tutor_id, duration_minutes, rate_per_hour 
    INTO v_tutor_id, v_duration_minutes, v_rate_per_hour
    FROM jobs 
    WHERE job_id = p_job_id AND status = 'open';

    -- Validate job exists and is open
    IF v_tutor_id IS NULL THEN
        SET p_status_msg = 'Error: Job not found or not available';
        SET p_booking_id = 0;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Job not available';
    END IF;

    -- Validate student exists
    IF NOT EXISTS (SELECT 1 FROM users WHERE student_id = p_student_id) THEN
        SET p_status_msg = 'Error: Invalid student ID';
        SET p_booking_id = 0;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid student';
    END IF;

    -- Validate dates
    IF p_scheduled_start_date >= p_scheduled_end_date THEN
        SET p_status_msg = 'Error: Invalid schedule dates';
        SET p_booking_id = 0;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid dates';
    END IF;

    -- Calculate final amount
    SET v_final_amount = (v_rate_per_hour * v_duration_minutes) / 60;

    START TRANSACTION;
        -- Create booking
        INSERT INTO booked_jobs (
            job_id,
            tutor_id,
            student_id,
            scheduled_start_date,
            scheduled_end_date,
            booking_status,
            payment_status,
            final_amount,
            meeting_link
        ) VALUES (
            p_job_id,
            v_tutor_id,
            p_student_id,
            p_scheduled_start_date,
            p_scheduled_end_date,
            'confirmed',
            'pending',
            v_final_amount,
            CONCAT('https://meet.example.com/session', p_job_id)
        );

        -- Update job status
        UPDATE jobs 
        SET status = 'assigned' 
        WHERE job_id = p_job_id;
        
        SET p_booking_id = LAST_INSERT_ID();
        SET p_status_msg = 'Success: Job booked successfully';
    COMMIT;
END //