-- Views --
DROP VIEW IF EXISTS HostingDepartmentProgramme;
DROP VIEW IF EXISTS Hosting;
DROP VIEW IF EXISTS NotHostingDepartmentProgramme;
DROP VIEW IF EXISTS NotHosting;

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
	SELECT Students.NIN, Students.name, Students.programme, ChosenBranch.branch FROM Students JOIN ChosenBranch ON Students.NIN = ChosenBranch.student;

-- FinishedCourses
-- For all students, all finished courses, along with their names, grades (grade 'U', '3', '4' or '5') and number of credits.
DROP VIEW IF EXISTS FinishedCourses;
CREATE VIEW FinishedCourses AS
	SELECT Students.name AS Student, Finished.grade, Courses.name AS Course, Courses.credits 
		FROM Students JOIN Finished ON Students.NIN = Finished.student 
			JOIN Courses ON Finished.course = Courses.code;

-- Registrations
-- All registered and waiting students for all courses, along with their waiting status ('registered' or 'waiting').
DROP VIEW IF EXISTS Registrations;
CREATE VIEW Registrations AS
	SELECT Students.name AS Student, C.course AS Course,
			CASE WHEN C.course IN (SELECT course FROM Registered) THEN 'Registered' ELSE 'WaitingOn' END AS Status
		FROM Students NATURAL JOIN
			((SELECT * FROM Students JOIN Registered ON Students.NIN = Registered.student) AS A
						NATURAL FULL JOIN (SELECT * FROM Students JOIN WaitingOn ON Students.NIN = WaitingOn.student) AS B) AS C;
			
-- PassedCourses
-- For all students, all passed courses, i.e. courses finished with a 
-- grade other than ‘U’, and the number of credits for those courses. 
-- This view is intended as a helper view towards the PathToGraduation
-- view (and for task 4), and will not be directly used by your application.
DROP VIEW IF EXISTS PassedCourses;
CREATE VIEW PassedCourses AS
	SELECT NIN, code, grade, credits FROM
		Courses JOIN
			(Students JOIN Finished 
				ON Students.NIN = Finished.student AND Finished.grade IN ('3','4','5')) 
			AS A
		ON Courses.code = A.course;

-- UnreadMandatory
-- For all students, the mandatory courses (branch and programme) they 
-- have not yet passed. This view is intended as a helper view towards 
-- the PathToGraduation view, and will not be directly used by your application.
DROP VIEW IF EXISTS UnreadMandatory;
CREATE VIEW UnreadMandatory AS
	SELECT Students.NIN, A.course FROM
		(SELECT programme,course FROM ProgrammeMandatory UNION SELECT programme,course from BranchMandatory) AS A
	JOIN
		Students ON A.programme = Students.programme AND 
			(Students.NIN,A.course) NOT IN (SELECT NIN,code FROM PassedCourses)
	ORDER BY NIN;
/*CREATE VIEW UnreadMandatory AS
	SELECT * FROM
		(SELECT Students.NIN, Students.name, ProgrammeMandatory.course FROM Students
			JOIN ProgrammeMandatory ON Students.programme = ProgrammeMandatory.Programme
		UNION
		SELECT Students.NIN, Students.name, BranchMandatory.course FROM Students
			JOIN BranchMandatory ON Students.programme = BranchMandatory.Programme) AS A
		WHERE NIN NOT IN (SELECT NIN FROM PassedCourses)
		ORDER BY NIN;*/

-- PathToGraduation
-- For all students, their path to graduation, i.e. a view with columns for
-- - the number of credits they have taken.
-- - the number of mandatory courses they have yet to read (branch or programme).
-- - the number of credits they have taken in courses that are classified as math courses.
-- - the number of credits they have taken in courses that are classified as research courses.
-- - the number of seminar courses they have read.
-- whether or not they qualify for graduation.
DROP VIEW IF EXISTS PathToGraduation;
CREATE VIEW PathToGraduation AS
	SELECT Students.NIN, Students.name, SUM(grade) FROM
	Students JOIN PassedCourses ON Students.NIN = PassedCourses.NIN
	GROUP BY Students.NIN;