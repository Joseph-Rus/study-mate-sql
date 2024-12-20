SET @test_pdf = 'This is some test content to simulate a PDF file. It can be any text content.';

CALL add_note(
    'Database Systems Homework',     -- title
    'EGR325',                        -- course_code
    'Database Systems',     -- course_title
    'Larry Clement',                    -- professor
    'John Doe',                     -- uploader_name
    'Comprehensive database notes',  -- description
    19.99,                          -- price
    'Fall 2024',                    -- semester
    @test_pdf,                      -- pdf_data (sample text as LONGBLOB)
    'johnsnotes.pdf',                    -- pdf_name
    123467                          -- uploader_id
);