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
	date	TEXT 		NOT NULL UNIQUE,
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
