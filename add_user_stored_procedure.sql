DELIMITER //

DROP PROCEDURE IF EXISTS add_user//

CREATE PROCEDURE add_user(
    IN p_student_id INT,
    IN p_full_name VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_password VARCHAR(255),
    IN p_role VARCHAR(50),
    OUT p_status VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status = 'Error: Unable to create user';
    END;

    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        SET p_status = 'Error: Email or Student ID already exists';
    END;

    START TRANSACTION;
    
    -- Validate inputs
    IF p_full_name IS NULL OR p_email IS NULL OR p_password IS NULL THEN
        SET p_status = 'Error: Required fields cannot be null';
        ROLLBACK;
    ELSE
        -- Insert new user with hashed password
        INSERT INTO users (
            student_id,
            full_name,
            email,
            password,
            role
        ) VALUES (
            p_student_id,
            TRIM(p_full_name),
            LOWER(TRIM(p_email)),
            SHA2(p_password, 256), -- Using SHA2 with 256-bit encryption
            COALESCE(p_role, 'student')
        );
        
        SET p_status = CONCAT('Success: User created with ID ', COALESCE(p_student_id, LAST_INSERT_ID()));
        COMMIT;
    END IF;
END //

DELIMITER ;