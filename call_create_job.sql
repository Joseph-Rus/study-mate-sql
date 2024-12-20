-- Declare variables to store output parameters
SET @job_id = 0;
SET @status_message = '';

-- Call the stored procedure
CALL create_job(
    1,                              -- tutor_id (replace with actual tutor ID)
    'Mathematics',                  -- subject
    'Advanced calculus tutoring',   -- description
    60,                            -- duration_minutes
    50.00,                         -- rate_per_hour
    'University',                  -- required_education_level
    'Interactive and hands-on',    -- preferred_teaching_style
    'Graphing calculator required',-- special_requirements
    @job_id,                       -- OUT parameter for job_id
    @status_message                -- OUT parameter for status_msg
);

-- Check the results
SELECT @job_id AS job_id, @status_message AS status_message;