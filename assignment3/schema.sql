DROP TABLE IF EXISTS Departments;
DROP TABLE IF EXISTS Programmes;
DROP TABLE IF EXISTS HostedBy;
DROP TABLE IF EXISTS Branches;
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS LimitedCourses;
DROP TABLE IF EXISTS Classifications;
DROP TABLE IF EXISTS HasClass;
DROP TABLE IF EXISTS WaitingOn;
DROP TABLE IF EXISTS Prerequisite;
DROP TABLE IF EXISTS ProgrammeMandatory;
DROP TABLE IF EXISTS BranchMandatory;
DROP TABLE IF EXISTS Recommended;
DROP TABLE IF EXISTS Registered;
DROP TABLE IF EXISTS Finished;

CREATE TABLE Departments (
	name			TEXT	NOT NULL PRIMARY KEY,
	abbreviation	TEXT	NOT NULL UNIQUE
);

CREATE TABLE Programmes (
	name			TEXT	NOT NULL PRIMARY KEY,
	abbreviation	TEXT	NOT	NULL
);

CREATE TABLE HostedBy (
	programme 		TEXT 	NOT NULL,
	department 		TEXT 	NOT NULL REFERENCES Departments(name),
	FOREIGN KEY (programme) REFERENCES Programmes(name) ,--ON DELETE CASCADE,
	PRIMARY KEY (programme,department)
);

CREATE TABLE Branches (
	name			TEXT	NOT NULL,
	programme 		TEXT 	NOT NULL,
	FOREIGN KEY (programme) REFERENCES Programmes(name) ,--ON DELETE CASCADE,
	PRIMARY KEY (name,programme)
);

CREATE TABLE Students (
	NIN 			CHAR(10) 	NOT NULL PRIMARY KEY,
	name 			TEXT 		NOT NULL,
	loginID 		TEXT 		NOT NULL UNIQUE,
	branch 			TEXT,
	programme 		TEXT,
	FOREIGN KEY (branch,programme) REFERENCES Branches(name,programme)
);

CREATE TABLE Courses (
	code		CHAR(6) NOT NULL PRIMARY KEY,
	name		TEXT NOT NULL,
	credits		REAL NOT NULL,
	department	TEXT NOT NULL REFERENCES Departments(name)
);

CREATE TABLE LimitedCourses (
	code			CHAR(6) NOT NULL REFERENCES Courses(code) PRIMARY KEY,
	studentLimit	INT		NOT NULL
);

CREATE TABLE Classifications (
	class	TEXT NOT NULL PRIMARY KEY
);

CREATE TABLE HasClass (
	course	CHAR(6) NOT NULL REFERENCES Courses(code),
	class	TEXT 	NOT NULL REFERENCES Classifications(class),
	PRIMARY KEY (course, class)
);

CREATE TABLE WaitingOn (
	course	CHAR(6) 	NOT NULL REFERENCES LimitedCourses(code),
	student	CHAR(11) 	NOT NULL REFERENCES Students(NIN),
	date	TEXT 		NOT NULL UNIQUE,
	PRIMARY KEY (course, student)
);

CREATE TABLE Prerequisite (
	prerequisite	CHAR(6) NOT NULL REFERENCES Courses(code),
	toCourse		CHAR(6) NOT NULL REFERENCES Courses(code),
	CHECK(NOT (prerequisite = toCourse))
	-- REMEMBER assertion for (c1 to c2 to c1)... 
);

CREATE TABLE ProgrammeMandatory (
	programme	TEXT 	NOT NULL REFERENCES Programmes(name),
	course		CHAR(6) NOT NULL REFERENCES Courses(code),
	PRIMARY KEY (programme, course)
);

CREATE TABLE BranchMandatory (
	branch		TEXT 	NOT NULL,
	programme	TEXT 	NOT NULL,
	course		CHAR(6) NOT NULL REFERENCES Courses(code),
	FOREIGN KEY (branch,programme) REFERENCES Branches(name,programme),
	PRIMARY KEY (programme, branch, course)
);

CREATE TABLE Recommended (
	branch		TEXT 	NOT NULL,
	programme	TEXT 	NOT NULL,
	course		CHAR(6) NOT NULL REFERENCES Courses(code),
	FOREIGN KEY (branch,programme) REFERENCES Branches(name,programme),
	PRIMARY KEY (programme, branch, course)
);

CREATE TABLE Registered (
	student	CHAR(11) 	NOT NULL REFERENCES Students(NIN),
	course	CHAR(6) 	NOT NULL REFERENCES Courses(code),
	PRIMARY KEY (student, course)
);

CREATE TABLE Finished (
	student	CHAR(11) 	NOT NULL REFERENCES Students(NIN),
	course	CHAR(6) 	NOT NULL REFERENCES Courses(code),
	grade	CHAR(1) 	NOT NULL CHECK(grade IN ('U', '3', '4', '5')),
	PRIMARY KEY (student, course)
);

---- Triggers --
--CREATE FUNCTION updateProgrammeChildren() RETURNS
--TRIGGER AS $$
--BEGIN
--	DELETE FROM Branches WHERE Branches.programme = OLD.name;
--	UPDATE Students SET programme = NULL WHERE Students.programme = OLD.name;
--	RETURN OLD;
--END
--$$ LANGUAGE 'plpgsql';

--CREATE TRIGGER ProgrammeDeleted
--	BEFORE DELETE ON Programmes
--	FOR EACH ROW
--	EXECUTE PROCEDURE updateProgrammeChildren();

--CREATE FUNCTION updateBranchChildren() RETURNS
--TRIGGER AS $$
--BEGIN
--	UPDATE Students SET branch = NULL WHERE Students.branch = OLD.name;
--	RETURN OLD;
--END
--$$ LANGUAGE 'plpgsql';

--CREATE TRIGGER BranchDeleted
--	BEFORE DELETE ON Branches
--	FOR EACH ROW
--	EXECUTE PROCEDURE updateBranchChildren();

/*CREATE Procedure testData AS
DECLARE iter INT = 0;
GO
BEGIN
	WHILE iter < 10 DO
		INSERT INTO Departments (name,abbreviation) VALUES ('Department' + CAST(iter AS TEXT),'D' + CAST(iter AS TEXT));
		SET iter = iter + 1;
	END WHILE
END*/


-- Test Data --
INSERT INTO Departments (name,abbreviation) VALUES ('Department1','D1');
INSERT INTO Departments (name,abbreviation) VALUES ('Department2','D2');
INSERT INTO Departments (name,abbreviation) VALUES ('Department3','D3');
INSERT INTO Departments (name,abbreviation) VALUES ('Department4','D4');
INSERT INTO Departments (name,abbreviation) VALUES ('Department5','D5');
INSERT INTO Departments (name,abbreviation) VALUES ('Department6','D6');

INSERT INTO Programmes (name,abbreviation) VALUES ('Programme1'	,'P1');
INSERT INTO Programmes (name,abbreviation) VALUES ('Programme2'	,'P2');
INSERT INTO Programmes (name,abbreviation) VALUES ('Programme3'	,'P3');
INSERT INTO Programmes (name,abbreviation) VALUES ('Programme4'	,'P4');
INSERT INTO Programmes (name,abbreviation) VALUES ('Programme5'	,'P5');
INSERT INTO Programmes (name,abbreviation) VALUES ('Programme6'	,'P6');
INSERT INTO Programmes (name,abbreviation) VALUES ('Programme7'	,'P7');
INSERT INTO Programmes (name,abbreviation) VALUES ('Programme8'	,'P8');
INSERT INTO Programmes (name,abbreviation) VALUES ('Programme9'	,'P9');
INSERT INTO Programmes (name,abbreviation) VALUES ('Programme10','P10');

INSERT INTO HostedBy (programme,department) VALUES ('Programme1' ,'Department1');
INSERT INTO HostedBy (programme,department) VALUES ('Programme1' ,'Department2');
INSERT INTO HostedBy (programme,department) VALUES ('Programme2' ,'Department3');
INSERT INTO HostedBy (programme,department) VALUES ('Programme2' ,'Department4');
INSERT INTO HostedBy (programme,department) VALUES ('Programme3' ,'Department5');
INSERT INTO HostedBy (programme,department) VALUES ('Programme3' ,'Department6');
INSERT INTO HostedBy (programme,department) VALUES ('Programme4' ,'Department1');
INSERT INTO HostedBy (programme,department) VALUES ('Programme4' ,'Department2');
INSERT INTO HostedBy (programme,department) VALUES ('Programme5' ,'Department3');
INSERT INTO HostedBy (programme,department) VALUES ('Programme5' ,'Department4');
INSERT INTO HostedBy (programme,department) VALUES ('Programme6' ,'Department5');
INSERT INTO HostedBy (programme,department) VALUES ('Programme6' ,'Department6');
INSERT INTO HostedBy (programme,department) VALUES ('Programme7' ,'Department1');
INSERT INTO HostedBy (programme,department) VALUES ('Programme7' ,'Department2');
INSERT INTO HostedBy (programme,department) VALUES ('Programme8' ,'Department3');
INSERT INTO HostedBy (programme,department) VALUES ('Programme8' ,'Department4');
INSERT INTO HostedBy (programme,department) VALUES ('Programme9' ,'Department5');
INSERT INTO HostedBy (programme,department) VALUES ('Programme9' ,'Department6');
INSERT INTO HostedBy (programme,department) VALUES ('Programme10','Department1');
INSERT INTO HostedBy (programme,department) VALUES ('Programme10','Department2');

INSERT INTO Branches (name,programme) VALUES ('Branch1','Programme1');
INSERT INTO Branches (name,programme) VALUES ('Branch2','Programme2');
INSERT INTO Branches (name,programme) VALUES ('Branch3','Programme3');
INSERT INTO Branches (name,programme) VALUES ('Branch4','Programme4');
INSERT INTO Branches (name,programme) VALUES ('Branch5','Programme5');
INSERT INTO Branches (name,programme) VALUES ('Branch6','Programme6');
INSERT INTO Branches (name,programme) VALUES ('Branch1','Programme7');
INSERT INTO Branches (name,programme) VALUES ('Branch2','Programme8');
INSERT INTO Branches (name,programme) VALUES ('Branch3','Programme9');
INSERT INTO Branches (name,programme) VALUES ('Branch4','Programme10');
INSERT INTO Branches (name,programme) VALUES ('Branch5','Programme1');
INSERT INTO Branches (name,programme) VALUES ('Branch6','Programme2');

INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150001','name1','loginId1','Branch1','Programme0');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150002','name2','loginId2','Branch2','Programme1');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150003','name3','loginId3','Branch3','Programme2');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150004','name4','loginId4','Branch4','Programme3');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150005','name5','loginId5','Branch5','Programme4');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150006','name6','loginId6','Branch6','Programme5');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150007','name7','loginId7','Branch1','Programme6');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150008','name8','loginId8','Branch2','Programme7');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150009','name9','loginId9','Branch3','Programme8');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150010','name10','loginId10','Branch4','Programme9');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150011','name11','loginId11','Branch5','Programme10');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150012','name12','loginId12','Branch6','Programme1');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150013','name13','loginId13','Branch1','Programme2');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150014','name14','loginId14','Branch2','Programme3');

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

SELECT * FROM Departments;
SELECT * FROM Programmes;
SELECT * FROM HostedBy;
SELECT * FROM Branches;
SELECT * FROM Students;