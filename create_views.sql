-- Create view for tutor profiles with aggregate statistics
CREATE OR REPLACE VIEW tutor_dashboard AS
SELECT 
    t.id AS tutor_id,
    u.full_name AS tutor_name,
    u.email,
    p.location,
    p.time_zone,
    t.verification_status,
    t.education_level,
    t.years_of_experience,
    t.hourly_rate,
    t.subjects_taught,
    t.availability,
    -- Job statistics
    COUNT(DISTINCT j.job_id) AS total_jobs_posted,
    COUNT(DISTINCT bj.booking_id) AS total_bookings,
    COUNT(DISTINCT pj.past_job_id) AS completed_jobs,
    -- Rating statistics
    ROUND(AVG(pj.student_rating), 2) AS average_rating,
    COUNT(DISTINCT CASE WHEN pj.student_rating = 5 THEN pj.past_job_id END) AS five_star_ratings,
    -- Financial statistics
    ROUND(SUM(bj.final_amount), 2) AS total_earnings,
    -- Time statistics
    SUM(pj.actual_duration_minutes) AS total_tutoring_minutes,
    -- Latest activity
    MAX(bj.scheduled_start_date) AS latest_session_date
FROM 
    tutors t
    INNER JOIN users u ON t.user_id = u.student_id
    LEFT JOIN profiles p ON u.student_id = p.user_id
    LEFT JOIN jobs j ON t.id = j.tutor_id
    LEFT JOIN booked_jobs bj ON j.job_id = bj.job_id
    LEFT JOIN past_jobs pj ON t.id = pj.tutor_id
GROUP BY 
    t.id, u.full_name, u.email, p.location, p.time_zone,
    t.verification_status, t.education_level, t.years_of_experience,
    t.hourly_rate, t.subjects_taught, t.availability;

-- Create view for student activity
CREATE OR REPLACE VIEW student_learning_history AS
SELECT 
    u.student_id,
    u.full_name AS student_name,
    u.email,
    p.location,
    COUNT(DISTINCT bj.booking_id) AS total_sessions_booked,
    COUNT(DISTINCT CASE WHEN bj.booking_status = 'completed' THEN bj.booking_id END) AS completed_sessions,
    ROUND(AVG(bj.final_amount), 2) AS average_session_cost,
    SUM(bj.final_amount) AS total_spent,
    -- Study materials
    COUNT(DISTINCT n.id) AS notes_uploaded,
    ROUND(SUM(n.price), 2) AS total_notes_revenue
FROM 
    users u
    LEFT JOIN profiles p ON u.student_id = p.user_id
    LEFT JOIN booked_jobs bj ON u.student_id = bj.student_id
    LEFT JOIN notes n ON u.student_id = n.uploader_id
WHERE 
    u.role = 'student'
GROUP BY 
    u.student_id, u.full_name, u.email, p.location;

-- Create view for course activity and popularity
CREATE OR REPLACE VIEW course_analytics AS
SELECT 
    n.course_code,
    n.course_title,
    COUNT(DISTINCT n.id) AS total_notes,
    COUNT(DISTINCT n.uploader_id) AS unique_contributors,
    ROUND(AVG(n.price), 2) AS average_note_price,
    MIN(n.price) AS lowest_price,
    MAX(n.price) AS highest_price,
    COUNT(DISTINCT j.job_id) AS related_tutoring_sessions,
    -- Get most recent semester this course had activity
    MAX(n.semester) AS latest_semester,
    -- Get professors teaching this course
    GROUP_CONCAT(DISTINCT n.professor) AS professors
FROM 
    notes n
    LEFT JOIN jobs j ON n.course_code = j.subject
GROUP BY 
    n.course_code, n.course_title;

-- Create view for active tutoring sessions
CREATE OR REPLACE VIEW active_tutoring_sessions AS
SELECT 
    bj.booking_id,
    u_student.full_name AS student_name,
    u_tutor.full_name AS tutor_name,
    j.subject,
    j.description,
    bj.scheduled_start_date,
    bj.scheduled_end_date,
    bj.final_amount,
    bj.meeting_link,
    bj.booking_status,
    bj.payment_status
FROM 
    booked_jobs bj
    INNER JOIN jobs j ON bj.job_id = j.job_id
    INNER JOIN users u_student ON bj.student_id = u_student.student_id
    INNER JOIN tutors t ON bj.tutor_id = t.id
    INNER JOIN users u_tutor ON t.user_id = u_tutor.student_id
WHERE 
    bj.booking_status IN ('confirmed', 'in_progress')
ORDER BY 
    bj.scheduled_start_date;