# study-mate-sql!
College Study Mate is a database system designed to support an academic platform that connects students with tutors, organizes study materials, and facilitates collaborative learning. The SQL database is structured to efficiently handle user data, manage relationships between different entities, and ensure the platform is scalable and flexible for future enhancements. I am working on the front end of the website, and for that, I am using React and Node.js, among others.

Preview:

![main home page](https://github.com/user-attachments/assets/dff61371-6779-48b8-8da1-388da44a6a61)


Key Skills used:

  MySQL Workbench: For designing, modeling, and managing the database schema.
  DataGrip: For advanced SQL querying, debugging, and seamless database interaction.
  AWS: To host the database in a secure, scalable, and highly available cloud environment.
  Jira: For project management, task tracking, and team collaboration.

Key Features:
Users Table:

  Stores student and tutor profiles.
  Includes fields like user_id (primary key), name, email, and role (student/tutor).
  Designed for user authentication and personalization.
  Tutors Table:
  
  Contains details about tutors, such as tutor_id (linked to user_id as a foreign key), expertise, and availability.
  Facilitates the connection of students to subject-specific tutors.
  Courses Table:
  
  Maintains information on available courses, including course codes, titles, and descriptions.
  Enables users to find and enroll in relevant study materials or sessions.
  Study Materials Table:
  
  Tracks uploaded resources such as PDFs, notes, and videos.
  Linked to user_id to identify contributors.
  Supports tagging and categorization for easy searching.
  Schedules Table:
  
  Manages tutoring session bookings and study group schedules.
  Tracks user_id, tutor_id, date, and time to organize sessions efficiently.
  Relationships and Efficiency:
  
  The database uses foreign keys to maintain relationships between tables, such as linking tutors to courses and users to study materials.
  Normalization ensures that the structure avoids redundancy and enhances data integrity.
  Key Functionalities:
  
  User registration and profile management.
  Resource uploads and tagging for study materials.
  Scheduling and booking for tutoring sessions or group studies.
  Filtering and searching for courses, tutors, or study materials.
  This SQL database is designed to provide a seamless experience for students and tutors while maintaining flexibility for future platform growth.


https://github.com/user-attachments/assets/3d486ed1-9caa-4cdb-ae56-b53a9bd367c7



https://github.com/user-attachments/assets/6133d866-07e8-48b0-a261-928e7e9f22d8



https://github.com/user-attachments/assets/464c348b-69a0-4b6c-82bb-fd728edc2a5f



https://github.com/user-attachments/assets/ea1d0707-776b-40b1-a09c-9fdfa091b657





[FINALERD drawio](https://github.com/user-attachments/assets/79e9a956-d834-450f-8055-8b2f824f89a0)
