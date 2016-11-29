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

--.print "========================================"
--.print "  HostingDepartmentProgramme"
--.print "========================================"
--SELECT * FROM HostingDepartmentProgramme;
--.print "========================================"
--.print "  NotHostingDepartmentProgramme"
--.print "========================================"
--SELECT * FROM NotHostingDepartmentProgramme;

DROP VIEW IF EXISTS StudentsAttendingProgramme;
CREATE VIEW StudentsAttendingProgramme AS
	SELECT Students.name AS Student,Programmes.name AS Programme FROM
		Students JOIN Programmes ON Students.programme = Programmes.name;

--.print "========================================"
--.print "  StudentsAttendingProgramme"
--.print "========================================"
--SELECT * FROM StudentsAttendingProgramme;
