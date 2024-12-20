DROP PROCEDURE IF EXISTS add_note;

DELIMITER //

CREATE PROCEDURE `add_note`(
    IN p_title VARCHAR(255),
    IN p_course_code VARCHAR(50),
    IN p_course_title VARCHAR(255),
    IN p_professor VARCHAR(255),
    IN p_uploader_name VARCHAR(255),
    IN p_description TEXT,
    IN p_price DECIMAL(10,2),
    IN p_semester VARCHAR(50),
    IN p_pdf_data LONGBLOB,
    IN p_pdf_name VARCHAR(255),
    IN p_uploader_id INT
)
BEGIN
    DECLARE user_exists INT;
    
    -- Check if uploader exists in users table
    SELECT COUNT(*) INTO user_exists 
    FROM users 
    WHERE student_id = p_uploader_id;

    -- Input validation
    IF p_title IS NULL OR TRIM(p_title) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Title cannot be empty';
    END IF;

    IF p_course_code IS NULL OR TRIM(p_course_code) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Course code cannot be empty';
    END IF;

    IF p_course_title IS NULL OR TRIM(p_course_title) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Course title cannot be empty';
    END IF;

    IF p_professor IS NULL OR TRIM(p_professor) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Professor name cannot be empty';
    END IF;

    IF p_uploader_name IS NULL OR TRIM(p_uploader_name) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Uploader name cannot be empty';
    END IF;

    IF p_price IS NULL OR p_price < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Price must be a non-negative value';
    END IF;

    IF p_semester IS NULL OR TRIM(p_semester) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Semester cannot be empty';
    END IF;

    IF p_uploader_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Uploader ID cannot be empty';
    END IF;

    IF user_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Uploader ID does not exist in users table';
    END IF;

    -- Validate semester format (assuming format like 'Fall 2023' or 'Spring 2024')
    IF NOT p_semester REGEXP '^(Fall|Spring|Summer|Winter)[[:space:]][0-9]{4}$' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid semester format. Use format: Season YYYY (e.g., Fall 2023)';
    END IF;

    -- Validate course code format (assuming format like 'CS101' or 'MATH200')
    IF NOT p_course_code REGEXP '^[A-Z]{2,4}[0-9]{3,4}$' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid course code format. Use format: DEPT101';
    END IF;

    START TRANSACTION;
    
    -- Insert new note
    INSERT INTO notes (
        title,
        course_code,
        course_title,
        professor,
        uploader_name,
        description,
        price,
        semester,
        pdf_data,
        pdf_name,
        uploader_id
    ) VALUES (
        TRIM(p_title),
        UPPER(TRIM(p_course_code)),
        TRIM(p_course_title),
        TRIM(p_professor),
        TRIM(p_uploader_name),
        IF(p_description IS NULL, '', TRIM(p_description)),
        p_price,
        TRIM(p_semester),
        p_pdf_data,    -- Now accepts NULL
        COALESCE(p_pdf_name, 'placeholder.pdf'),  -- Default name if NULL
        p_uploader_id
    );

    -- Get the ID of the newly inserted note
    SELECT LAST_INSERT_ID() as note_id, 'Note successfully added' as message;

    COMMIT;

END //

DELIMITER ;