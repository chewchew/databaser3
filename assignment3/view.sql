-- Views --
/*DROP VIEW IF EXISTS HostingDepartmentProgramme;
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
		*/
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
DROP VIEW IF EXISTS PassedCourses CASCADE;
CREATE VIEW PassedCourses AS
	SELECT NIN, course, grade, credits FROM
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
			(Students.NIN,A.course) NOT IN (SELECT NIN,course FROM PassedCourses)
	ORDER BY NIN;

-- PathToGraduation
-- For all students, their path to graduation, i.e. a view with columns for
-- - the number of credits they have taken.
-- - the number of mandatory courses they have yet to read (branch or programme).
-- - the number of credits they have taken in courses that are classified as math courses.
-- - the number of credits they have taken in courses that are classified as research courses.
-- - the number of seminar courses they have read.
-- whether or not they qualify for graduation.
-- 		10hp recommended branch
-- 		20hp math
-- 		10hp research
-- 		1 seminar course
DROP VIEW IF EXISTS PathToGraduation;
CREATE VIEW PathToGraduation AS
	SELECT 
		Passed.NIN, 
		CollectedCredits, 
		CASE WHEN UnreadCourses IS NULL THEN 0 ELSE UnreadCourses END,
		CASE WHEN MathCredits IS NULL THEN 0 ELSE MathCredits END,
		CASE WHEN ResearchCredits IS NULL THEN 0 ELSE ResearchCredits END,
		CASE WHEN ReadSeminarCourses IS NULL THEN 0 ELSE ReadSeminarCourses END,
		CASE WHEN 
			UnreadCourses IS NULL AND 
			MathCredits >= 20 AND
			ResearchCredits >= 10 AND
			ReadSeminarCourses > 0 AND
			CollectedRecommendedCredits >= 10
			THEN 'Does Qualify'
			ELSE 'Does Not Qualify'
		END AS Graduation
	FROM
	(SELECT NIN,SUM(credits) AS CollectedCredits 
		FROM PassedCourses 
		GROUP BY NIN) AS Passed
	LEFT OUTER JOIN
	(SELECT NIN,SUM(credits) AS CollectedRecommendedCredits 
		FROM PassedCourses 
		WHERE PassedCourses.course IN
			(SELECT course 
				FROM Recommended
				WHERE Recommended.programme IN
					(SELECT programme FROM Students WHERE Students.NIN = NIN))
		GROUP BY NIN) AS PassedRecommended
	ON Passed.NIN = PassedRecommended.NIN
	LEFT OUTER JOIN
	(SELECT NIN,COUNT(course) AS UnreadCourses
		FROM UnreadMandatory
		GROUP BY NIN) AS Unread
	ON Passed.NIN = Unread.NIN
	LEFT OUTER JOIN
	(SELECT NIN,SUM(credits) AS MathCredits
		FROM HasClass JOIN PassedCourses
		ON HasClass.course = PassedCourses.course AND HasClass.class = 'Math'
		GROUP BY NIN) AS PassedMath
	ON Passed.NIN = PassedMath.NIN
	LEFT OUTER JOIN
	(SELECT NIN,SUM(credits) AS ResearchCredits
		FROM HasClass JOIN PassedCourses
		ON HasClass.course = PassedCourses.course AND HasClass.class = 'Research'
		GROUP BY NIN) AS PassedResearch
	ON Passed.NIN = PassedResearch.NIN
	LEFT OUTER JOIN
	(SELECT NIN,COUNT(credits) AS ReadSeminarCourses
		FROM HasClass JOIN PassedCourses
		ON HasClass.course = PassedCourses.course AND HasClass.class = 'Seminar'
		GROUP BY NIN) AS ReadSeminar
	ON Passed.NIN = ReadSeminar.NIN;

			--AND (HasClass.class = 'Math' OR HasClass.class = 'Research')
		/*(SELECT Students.NIN, credits FROM
			Students JOIN PassedCourses ON Students.NIN = PassedCourses.NIN) AS Passed*/
		/*JOIN
		(SELECT Students.NIN, course FROM
			Students JOIN UnreadMandatory ON Students.NIN = UnreadMandatory.NIN) AS NotPassed
		ON Passed.NIN = NotPassed.NIN*/