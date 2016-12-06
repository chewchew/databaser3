DROP VIEW IF EXISTS HostingDepartmentProgramme;
DROP VIEW IF EXISTS Hosting;
DROP VIEW IF EXISTS NotHostingDepartmentProgramme;
DROP VIEW IF EXISTS NotHosting;
DROP VIEW IF EXISTS StudentsAttendingProgramme;

DROP VIEW IF EXISTS PathToGraduation;
DROP VIEW IF EXISTS UnreadMandatory;
DROP VIEW IF EXISTS PassedCourses;
DROP VIEW IF EXISTS Registrations;
DROP VIEW IF EXISTS FinishedCourses;
DROP VIEW IF EXISTS StudentsFollowing;

-- in backwards order since psql complains
-- about tables depending on other tables
DROP TABLE IF EXISTS Finished;
DROP TABLE IF EXISTS Registered;
DROP TABLE IF EXISTS Recommended;
DROP TABLE IF EXISTS BranchMandatory;
DROP TABLE IF EXISTS ProgrammeMandatory;
DROP TABLE IF EXISTS Prerequisite;
DROP TABLE IF EXISTS WaitingOn;
DROP TABLE IF EXISTS HasClass;
DROP TABLE IF EXISTS Classifications;
DROP TABLE IF EXISTS LimitedCourses;
DROP TABLE IF EXISTS ChosenBranch;
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Branches;
DROP TABLE IF EXISTS HostedBy;
DROP TABLE IF EXISTS Programmes;
DROP TABLE IF EXISTS Departments;

