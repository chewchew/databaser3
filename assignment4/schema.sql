DROP VIEW IF EXISTS HostingDepartmentProgramme CASCADE;
DROP VIEW IF EXISTS Hosting CASCADE;
DROP VIEW IF EXISTS NotHostingDepartmentProgramme CASCADE;
DROP VIEW IF EXISTS NotHosting CASCADE;
DROP VIEW IF EXISTS StudentsAttendingProgramme CASCADE;

DROP VIEW IF EXISTS PathToGraduation CASCADE;
DROP VIEW IF EXISTS UnreadMandatory CASCADE;
DROP VIEW IF EXISTS PassedCourses CASCADE;
DROP VIEW IF EXISTS Registrations CASCADE;
DROP VIEW IF EXISTS FinishedCourses CASCADE;
DROP VIEW IF EXISTS StudentsFollowing CASCADE;

-- in backwards order since psql complains
-- about tables depending on other tables
DROP TABLE IF EXISTS Finished CASCADE;
DROP TABLE IF EXISTS Registered CASCADE;
DROP TABLE IF EXISTS Recommended CASCADE;
DROP TABLE IF EXISTS BranchMandatory CASCADE;
DROP TABLE IF EXISTS ProgrammeMandatory CASCADE;
DROP TABLE IF EXISTS Prerequisite CASCADE;
DROP TABLE IF EXISTS WaitingOn CASCADE;
DROP TABLE IF EXISTS HasClass CASCADE;
DROP TABLE IF EXISTS Classifications CASCADE;
DROP TABLE IF EXISTS LimitedCourses CASCADE;
DROP TABLE IF EXISTS ChosenBranch CASCADE;
DROP TABLE IF EXISTS Students CASCADE;
DROP TABLE IF EXISTS Courses CASCADE;
DROP TABLE IF EXISTS Branches CASCADE;
DROP TABLE IF EXISTS HostedBy CASCADE;
DROP TABLE IF EXISTS Programmes CASCADE;
DROP TABLE IF EXISTS Departments CASCADE;

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
	FOREIGN KEY (programme) REFERENCES Programmes(name),
	PRIMARY KEY (programme,department)
);

CREATE TABLE Branches (
	name			TEXT	NOT NULL,
	programme 		TEXT 	NOT NULL,
	FOREIGN KEY (programme) REFERENCES Programmes(name),
	PRIMARY KEY (name,programme)
);

CREATE TABLE Students (
	NIN 			CHAR(10) 	NOT NULL PRIMARY KEY,
	name 			TEXT 		NOT NULL,
	loginID 		TEXT 		NOT NULL UNIQUE,
	programme 		TEXT		NOT NULL REFERENCES Programmes(name)
);

CREATE TABLE ChosenBranch (
	student 		CHAR(10) 	NOT NULL REFERENCES Students(NIN) PRIMARY KEY,
	branch 			TEXT 		NOT NULL,
	programme 		TEXT 		NOT NULL
);

CREATE TABLE Courses (
	code		CHAR(6) NOT NULL PRIMARY KEY,
	name		TEXT NOT NULL,
	credits		REAL NOT NULL,
	department	TEXT NOT NULL REFERENCES Departments(name)
);

CREATE TABLE LimitedCourses (
	code			CHAR(6) NOT NULL REFERENCES Courses(code) PRIMARY KEY,
	studentLimit	INT		NOT NULL CHECK(studentLimit >= 0)
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
	date	TIME 		NOT NULL UNIQUE,
	PRIMARY KEY (course, student)
);

CREATE TABLE Prerequisite (
	prerequisite	CHAR(6) NOT NULL REFERENCES Courses(code),
	toCourse		CHAR(6) NOT NULL REFERENCES Courses(code),
	PRIMARY KEY (prerequisite, toCourse),
	CHECK(NOT (prerequisite = toCourse))
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
