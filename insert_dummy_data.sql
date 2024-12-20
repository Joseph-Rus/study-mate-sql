-- Disable foreign key checks temporarily to allow for clean deletion
SET FOREIGN_KEY_CHECKS = 0;

-- Clear all existing data
TRUNCATE TABLE verification_tokens;
TRUNCATE TABLE past_jobs;
TRUNCATE TABLE booked_jobs;
TRUNCATE TABLE jobs;
TRUNCATE TABLE notes;
TRUNCATE TABLE tutors;
TRUNCATE TABLE profiles;
TRUNCATE TABLE users;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- First, create some users
CALL add_user(000001, 'John Smith', 'john.smith@university.edu', 'password123', 'student', @status);
CALL add_user(000002, 'Sarah Johnson', 'sarah.j@university.edu', 'password123', 'student', @status);
CALL add_user(000003, 'Michael Brown', 'michael.b@university.edu', 'password123', 'student', @status);
CALL add_user(000004, 'Emma Wilson', 'emma.w@university.edu', 'password123', 'student', @status);
CALL add_user(000005, 'David Lee', 'david.l@university.edu', 'password123', 'student', @status);

-- Verify users (since there's no stored procedure for this, we'll do it directly)
UPDATE users 
SET verified = 1 
WHERE student_id IN (000001, 000002, 000003, 000004, 000005);

-- Create profiles for users
CALL add_profile(000001, 'https://example.com/avatar1.jpg', 'Computer Science major, love coding!', '+1234567890', 'New York', 'EST', 'English, Spanish', '{"linkedin": "john-smith", "twitter": "@johnsmith"}', @status_msg);
CALL add_profile(000002, 'https://example.com/avatar2.jpg', 'Math enthusiast', '+1234567891', 'Los Angeles', 'PST', 'English, French', '{"linkedin": "sarah-johnson"}', @status_msg);
CALL add_profile(000003, 'https://example.com/avatar3.jpg', 'Physics PhD student', '+1234567892', 'Chicago', 'CST', 'English, Mandarin', '{"linkedin": "michael-brown"}', @status_msg);
CALL add_profile(000004, 'https://example.com/avatar4.jpg', 'Chemistry major', '+1234567893', 'Boston', 'EST', 'English, German', '{"linkedin": "emma-wilson"}', @status_msg);
CALL add_profile(000005, 'https://example.com/avatar5.jpg', 'Engineering student', '+1234567894', 'Seattle', 'PST', 'English, Korean', '{"linkedin": "david-lee"}', @status_msg);

-- Add some users as tutors
CALL add_user_as_tutor(000001, 'Bachelor', 2, 25.00, 'Computer Science, Programming, Data Structures', '{"monday": ["9:00-17:00"], "wednesday": ["9:00-17:00"], "friday": ["9:00-17:00"]}');
CALL add_user_as_tutor(000002, 'Master', 3, 30.00, 'Mathematics, Calculus, Linear Algebra', '{"tuesday": ["10:00-18:00"], "thursday": ["10:00-18:00"]}');
CALL add_user_as_tutor(000003, 'PhD', 5, 40.00, 'Physics, Quantum Mechanics', '{"monday": ["13:00-21:00"], "wednesday": ["13:00-21:00"]}');

-- Create some notes
SET @pdf_data = "This is a test string to fill in data for now"; -- In a real scenario, this would be actual PDF data
CALL add_note(
    'Introduction to Python Programming',
    'CS101',
    'Introduction to Computer Science',
    'Dr. Johnson',
    'John Smith',
    'Comprehensive notes on Python basics including variables, loops, and functions',
    9.99,
    'Fall 2023',
    @pdf_data,
    'python_basics.pdf',
    000001
);

CALL add_note(
    'Calculus I Study Guide',
    'MATH201',
    'Calculus I',
    'Dr. Williams',
    'Sarah Johnson',
    'Complete study guide covering limits, derivatives, and integrals',
    14.99,
    'Spring 2023',
    @pdf_data,
    'calculus_guide.pdf',
    000002
);

CALL add_note(
    'Physics Mechanics Notes',
    'PHYS301',
    'Classical Mechanics',
    'Dr. Brown',
    'Michael Brown',
    'Detailed notes on Newtonian mechanics and applications',
    12.99,
    'Fall 2023',
    @pdf_data,
    'mechanics_notes.pdf',
    000003
);

UPDATE tutors SET verification_status = 'approved' WHERE user_id IN (000001, 000002, 000003);
-- Create some tutoring jobs
SELECT @tutor1_id := id FROM tutors WHERE user_id = 000001;
SELECT @tutor2_id := id FROM tutors WHERE user_id = 000002;
SELECT @tutor3_id := id FROM tutors WHERE user_id = 000003;

-- Create some tutoring jobs using the actual tutor IDs
CALL create_job(@tutor1_id, 'Python Programming', 'Help with basic Python programming concepts', 60, 25.00, 'Beginner', 'Interactive', 'Bring your laptop', @job_id, @status_msg);
CALL create_job(@tutor2_id, 'Calculus', 'Help with derivatives and integrals', 90, 30.00, 'Intermediate', 'Problem-based', 'Have your textbook ready', @job_id, @status_msg);
CALL create_job(@tutor3_id, 'Physics', 'Quantum mechanics tutoring', 120, 40.00, 'Advanced', 'Theoretical', 'Prerequisites: Linear Algebra', @job_id, @status_msg);

-- Wait for a moment to ensure jobs are created
SELECT SLEEP(1);

-- Get job IDs
SELECT @job1_id := job_id FROM jobs WHERE tutor_id = @tutor1_id LIMIT 1;
SELECT @job2_id := job_id FROM jobs WHERE tutor_id = @tutor2_id LIMIT 1;

-- Book some jobs
CALL book_job(@job1_id, 000004, '2024-01-20 10:00:00', '2024-01-20 11:00:00', @booking_id, @status_msg);
CALL book_job(@job2_id, 000005, '2024-01-21 14:00:00', '2024-01-21 15:30:00', @booking_id, @status_msg);

-- Wait for a moment to ensure bookings are created
SELECT SLEEP(1);

-- Complete some jobs (creating past jobs)
CALL complete_job(1, 65, 5, 'Excellent tutor, very helpful!', 'Student showed great progress', @status_msg);
CALL complete_job(2, 95, 4, 'Very knowledgeable tutor', 'Covered all planned topics', @status_msg);

-- For verification, you can check the data with these queries:
SELECT 'Users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'Profiles', COUNT(*) FROM profiles
UNION ALL
SELECT 'Tutors', COUNT(*) FROM tutors
UNION ALL
SELECT 'Notes', COUNT(*) FROM notes
UNION ALL
SELECT 'Jobs', COUNT(*) FROM jobs
UNION ALL
SELECT 'Booked Jobs', COUNT(*) FROM booked_jobs
UNION ALL
SELECT 'Past Jobs', COUNT(*) FROM past_jobs;