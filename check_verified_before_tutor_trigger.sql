DELIMITER //

CREATE TRIGGER check_verified_before_tutor
BEFORE INSERT ON tutors
FOR EACH ROW
BEGIN
    DECLARE is_verified BOOLEAN;
    
    -- Check if user is verified
    SELECT verified INTO is_verified
    FROM users
    WHERE student_id = NEW.user_id;
    
    -- If user is not verified, prevent insert
    IF NOT is_verified THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Cannot add unverified user as tutor. User must be verified first.';
    END IF;
END //

DELIMITER ;