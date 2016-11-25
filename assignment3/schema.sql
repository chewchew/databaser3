DROP TABLE IF EXISTS Departments;
DROP TABLE IF EXISTS Programmes;
DROP TABLE IF EXISTS HostedBy;
DROP TABLE IF EXISTS Branches;
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS Test;

CREATE TABLE Departments (
	name			TEXT	NOT NULL,
	abbreviation	TEXT	NOT NULL UNIQUE,
	PRIMARY KEY (name)
);

CREATE TABLE Programmes (
	name			TEXT	NOT NULL,
	abbreviation	TEXT	NOT	NULL,
	PRIMARY KEY (name)
);

CREATE TABLE HostedBy (
	programme 		TEXT 	NOT NULL,
	department 		TEXT 	NOT NULL REFERENCES Departments(name),
	FOREIGN KEY (programme) REFERENCES Programmes(name) ON DELETE CASCADE,
	PRIMARY KEY (programme,department)
);

CREATE TABLE Branches (
	name			TEXT	NOT NULL,
	programme 		TEXT 	NOT NULL,
	FOREIGN KEY (programme) REFERENCES Programmes(name) ON DELETE CASCADE,
	PRIMARY KEY (name,programme)
);

CREATE TABLE Students (
	NIN 			CHAR(11) NOT NULL,
	name 			TEXT 	NOT NULL,
	loginID 		TEXT 	NOT NULL UNIQUE,
	branch 			TEXT,
	programme 		TEXT,
	FOREIGN KEY (branch,programme) REFERENCES Branches(name,programme),
	PRIMARY KEY (NIN)
);

-- Triggers --
CREATE FUNCTION updateProgrammeChildren() RETURNS
TRIGGER AS $$
BEGIN
	DELETE FROM Branches WHERE Branches.programme = OLD.name;
	UPDATE Students SET programme = NULL WHERE Students.programme = OLD.name;
	RETURN OLD;
END
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER ProgrammeDeleted
	BEFORE DELETE ON Programmes
	FOR EACH ROW
	EXECUTE PROCEDURE updateProgrammeChildren();

CREATE FUNCTION updateBranchChildren() RETURNS
TRIGGER AS $$
BEGIN
	UPDATE Students SET branch = NULL WHERE Students.branch = OLD.name;
	RETURN OLD;
END
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER BranchDeleted
	BEFORE DELETE ON Branches
	FOR EACH ROW
	EXECUTE PROCEDURE updateBranchChildren();

-- Test Data --
INSERT INTO Departments (name,abbreviation) VALUES ('Computer Science','CS');
INSERT INTO Departments (name,abbreviation) VALUES ('Physics','PS');
INSERT INTO Departments (name,abbreviation) VALUES ('Chemistry','CH');

INSERT INTO Programmes (name,abbreviation) VALUES ('Software Engineering','SE');
INSERT INTO Programmes (name,abbreviation) VALUES ('Computer Engineering','CE');

INSERT INTO HostedBy (programme,department) VALUES ('Software Engineering','Computer Science');
INSERT INTO HostedBy (programme,department) VALUES ('Computer Engineering','Computer Science');

INSERT INTO Branches (name,programme) VALUES ('Interaction Design','Software Engineering');
INSERT INTO Branches (name,programme) VALUES ('Software Engineering & Technology','Software Engineering');
INSERT INTO Branches (name,programme) VALUES ('Algorithms, Languages & Logic','Computer Engineering');

INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('000001-0001','Johan Gerdin','gejohan','Interaction Design','Software Engineering');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('000002-0002','Lars Engstrom','englar','Software Engineering & Technology','Software Engineering');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('000003-0003','Lisa Hjalmarsson','hjalisa','Algorithms, Languages & Logic','Computer Engineering');

-- Display Tables --
--.print "========================================"
--.print "  Departments"
--.print "========================================"
--SELECT * FROM Departments;
--.print "========================================"
--.print "  Programmes"
--.print "========================================"
--SELECT * FROM Programmes;
--.print "========================================"
--.print "  HostedBy"
--.print "========================================"
--SELECT * FROM HostedBy;
--.print "========================================"
--.print "  Branches"
--.print "========================================"
--SELECT * FROM Branches;
--.print "========================================"
--.print "  Students"
--.print "========================================"
--SELECT * FROM Students;

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

SELECT * FROM Programmes;
SELECT * FROM Branches;
SELECT * FROM Students;
DELETE FROM Programmes WHERE Programmes.name = 'Software Engineering';
--DELETE FROM Branches WHERE Branches.name = 'Interaction Design';
SELECT * FROM Programmes;
SELECT * FROM Branches;
SELECT * FROM Students;