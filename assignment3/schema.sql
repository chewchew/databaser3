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


