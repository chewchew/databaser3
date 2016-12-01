-- Views --
DROP VIEW IF EXISTS Hosting;
DROP VIEW IF EXISTS HostingDepartmentProgramme;
DROP VIEW IF EXISTS NotHosting;
DROP VIEW IF EXISTS NotHostingDepartmentProgramme;

CREATE VIEW Hosting AS
	SELECT * FROM Departments 
		WHERE Departments.name IN
			(SELECT department FROM HostedBy);

CREATE VIEW HostingDepartmentProgramme AS
	SELECT 	Hosting.name AS department,
			Hosting.abbreviation AS deptAbbreviation,
			Programmes.name AS programme,
			Programmes.abbreviation AS progAbbreviation
		FROM Hosting NATURAL JOIN HostedBy 
			JOIN Programmes ON HostedBy.programme = Programmes.name;

CREATE VIEW NotHosting AS
	SELECT * FROM Departments 
		WHERE Departments.name NOT IN
			(SELECT department FROM HostedBy);

CREATE VIEW NotHostingDepartmentProgramme AS
	SELECT 	NotHosting.name AS department,
			NotHosting.abbreviation AS deptAbbreviation,
			Programmes.name AS programme,
			Programmes.abbreviation AS progAbbreviation
		FROM NotHosting NATURAL JOIN HostedBy 
			JOIN Programmes ON HostedBy.programme = Programmes.name;

DROP VIEW IF EXISTS StudentsAttendingProgramme;
CREATE VIEW StudentsAttendingProgramme AS
	SELECT Students.name AS Student,Programmes.name AS Programme FROM
		Students JOIN Programmes ON Students.programme = Programmes.name;
		
-- StudentsFollowing
-- For all students, their basic information (name etc.), and the programme and branch (if any) they are following.
DROP VIEW IF EXISTS StudentsFollowing;
CREATE VIEW StudentsFollowing AS
	SELECT * FROM Students NATURAL JOIN ChosenBranch NATURAL JOIN Branches NATURAL JOIN Programmes;
-- FinishedCourses
-- For all students, all finished courses, along with their names, grades (grade 'U', '3', '4' or '5') and number of credits.

-- Registrations
-- All registered and waiting students for all courses, along with their waiting status ('registered' or 'waiting').

-- PassedCourses
-- For all students, all passed courses, i.e. courses finished with a grade other than ‘U’, and the number of credits for those courses. This view is intended as a helper view towards the PathToGraduation view (and for task 4), and will not be directly used by your application.

-- UnreadMandatory
-- For all students, the mandatory courses (branch and programme) they have not yet passed. This view is intended as a helper view towards the PathToGraduation view, and will not be directly used by your application.

-- PathToGraduation
-- For all students, their path to graduation, i.e. a view with columns for
-- - the number of credits they have taken.
-- - the number of mandatory courses they have yet to read (branch or programme).
-- - the number of credits they have taken in courses that are classified as math courses.
-- - the number of credits they have taken in courses that are classified as research courses.
-- - the number of seminar courses they have read.
-- whether or not they qualify for graduation.

