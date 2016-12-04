DROP VIEW IF EXISTS HostingDepartmentProgramme;
DROP VIEW IF EXISTS Hosting;
DROP VIEW IF EXISTS NotHostingDepartmentProgramme;
DROP VIEW IF EXISTS NotHosting;
DROP VIEW IF EXISTS StudentsAttendingProgramme;
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

CREATE OR REPLACE FUNCTION checkBranchInProgramme() 
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.branch IN (SELECT Branches.name FROM Branches WHERE Branches.programme = NEW.programme) THEN
		RETURN NEW;
	ELSE
		RAISE 'Branch -> % not in programme -> %', NEW.branch,New.programme;
	END IF;
	RETURN NEW;
END
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER branchInProgramme BEFORE INSERT ON ChosenBranch
	FOR EACH ROW EXECUTE PROCEDURE checkBranchInProgramme();

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
	PRIMARY KEY (prerequisite, toCourse),
	CHECK(NOT (prerequisite = toCourse))
	-- REMEMBER assertion for (c1 to c2 to c1)... 
);

-- something like this? (this does not work)
-- some join operation where left-most column shouldnt
-- match any of the right-most column?
-- CREATE OR REPLACE FUNCTION checkCycle3()
-- RETURNS TRIGGER AS $$
-- BEGIN
-- 	CREATE TEMP TABLE tmp AS (SELECT * FROM Prerequisite WHERE Prerequisite.prerequisite = NEW.toCourse);
-- 	WHILE (EXISTS (SELECT * FROM tmp NATURAL JOIN Prerequisite WHERE tmp.toCourse = Prerequisite.prerequisite)) LOOP
-- 		CREATE TABLE tmp2 AS SELECT * FROM tmp NATURAL JOIN Prerequisite WHERE tmp.toCourse = Prerequisite.prerequisite;
--         DROP TABLE tmp;
--         ALTER TABLE tmp2 RENAME TO tmp;
--         IF EXISTS (SELECT * FROM tmp WHERE NEW.prerequisite = tmp.prerequisite) THEN
--             RAISE 'Cycle detected: % -> %',NEW.prerequisite, NEW.toCourse;
--         END IF;

-- 	END LOOP;
	
--  	RETURN NEW;
-- END
-- $$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION checkCycle()
RETURNS TRIGGER AS $$
DECLARE
    arr bpchar[];
BEGIN
    CREATE TEMP TABLE prereq AS SELECT * FROM Prerequisite;
    INSERT INTO prereq VALUES (NEW.prerequisite, NEW.toCourse);
    IF EXISTS (
       WITH RECURSIVE prev AS (
            SELECT p.prerequisite, 1 AS depth, arr || p.prerequisite  as seen, false as cycle
            FROM prereq p
            WHERE p.prerequisite = NEW.toCourse
            UNION ALL
            SELECT p.prerequisite, prev.depth + 1, seen || p.prerequisite as seen, p.prerequisite = any(seen) as cycle
            FROM prev
            INNER JOIN prereq p on prev.prerequisite = p.toCourse
            AND prev.cycle = false
        )
        SELECT 1 
        FROM prev
        WHERE cycle
        LIMIT 1
        )
    THEN
        DROP TABLE prereq;
        RAISE 'Cycle detected: % -> %',NEW.prerequisite, NEW.toCourse;
    ELSE
        DROP TABLE prereq;
        RETURN NEW;
    END IF; 

END
$$ LANGUAGE 'plpgsql';


-- CREATE OR REPLACE FUNCTION checkCycle2()
-- RETURNS TRIGGER AS $$
-- DECLARE
-- 	_prerequisite CHAR(6);
-- 	_toCourse CHAR(6);
-- BEGIN
-- 	SELECT * INTO _prerequisite,_toCourse FROM Prerequisite WHERE NEW.toCourse = Prerequisite.prerequisite;
-- 	WHILE _toCourse IS NOT NULL LOOP
-- 		IF _prerequisite = NEW.prerequisite THEN
-- 			RAISE 'Cycle detected: % -> %',NEW.prerequisite,_prerequisite;
-- 		END IF;
-- 		SELECT * INTO _prerequisite,_toCourse FROM Prerequisite WHERE _toCourse = Prerequisite.prerequisite;
-- 	END LOOP;
-- 	RETURN NEW;
-- END
-- $$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS cycle ON Prerequisite;
CREATE TRIGGER cycle BEFORE INSERT ON Prerequisite
	FOR EACH ROW EXECUTE PROCEDURE checkCycle();

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

CREATE OR REPLACE FUNCTION hasClearedPrerequisites() 
RETURNS TRIGGER AS $$
DECLARE
    arr bpchar[];
BEGIN
	CREATE TEMP TABLE prereq AS SELECT * FROM Prerequisite WHERE NEW.course = Prerequisite.toCourse; --all prereq to intresting course
    CREATE TEMP TABLE fin AS SELECT course FROM Finished WHERE NEW.student = Finished.student; -- student's finished courses
    IF EXISTS (
      WITH RECURSIVE prev AS (
                SELECT p.prerequisite, arr || NEW.course || p.prerequisite AS seen, p.prerequisite IN (SELECT * FROM fin) AS qualified
                FROM Prerequisite p
                WHERE p.toCourse = NEW.course
                UNION ALL
                SELECT p.prerequisite, seen || p.prerequisite As seen, prev.prerequisite IN (SELECT * FROM fin) AS qualified
                FROM prev
                INNER JOIN Prerequisite p ON prev.prerequisite = p.toCourse
        )
        SELECT  
        FROM prev
        WHERE NOT qualified
        LIMIT 1
    ) 
    THEN 
        DROP TABLE IF EXISTS fin;
        DROP TABLE IF EXISTS prereq;
        RAISE 'Student % have not taken all prerequisite courses for course %', NEW.student, NEW.course;
    ELSE
        DROP TABLE IF EXISTS fin;
        DROP TABLE IF EXISTS prereq;
        IF EXISTS (SELECT code FROM LimitedCourses WHERE LimitedCourses.code = NEW.course) THEN
            IF (SELECT studentLimit FROM LimitedCourses WHERE LimitedCourses.code = NEW.course) > 0 THEN
                UPDATE LimitedCourses SET studentLimit = studentLimit - 1
                WHERE LimitedCourses.code = NEW.course;
            RETURN NEW;
            ELSE
                INSERT INTO WaitingOn VALUES (NEW.course, NEW.student, CURRENT_TIME);
                RETURN NULL;
            END IF;
        ELSE
            RETURN NEW;
        END IF;
    END IF;
END
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER check_qualifications BEFORE INSERT ON Registered
	FOR EACH ROW EXECUTE PROCEDURE hasClearedPrerequisites();

CREATE TABLE Finished (
	student	CHAR(11) 	NOT NULL REFERENCES Students(NIN),
	course	CHAR(6) 	NOT NULL REFERENCES Courses(code),
	grade	CHAR(1) 	NOT NULL CHECK(grade IN ('U', '3', '4', '5')),
	PRIMARY KEY (student, course)
);
