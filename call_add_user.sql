SET @status_msg = '';

-- Test Case 1: Add a regular student
CALL add_user(
    000001,                           -- student_id
    'John Smith',                   -- full_name
    'john.smith@university.edu',    -- email
    'SecurePass123!',              -- password
    'student',                     -- role
    @status_msg                    -- OUT parameter for status
);
-- Check the result
SELECT @status_msg AS 'Test Case 1 Result';