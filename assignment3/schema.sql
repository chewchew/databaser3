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
    student         CHAR(10)    NOT NULL REFERENCES Students(NIN) PRIMARY KEY,
    branch          TEXT        NOT NULL,
    programme       TEXT        NOT NULL,
    FOREIGN KEY (branch,programme) REFERENCES Branches(name,programme)
);

--------------------------------------------------------------------------------
-- This trigger function does:
-- - check that a chosen branch actually belong to the program the student
--   is enrolled in.
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION checkBranchInProgramme() 
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.programme <> (SELECT programme FROM Students WHERE NIN = NEW.student)
    THEN
        RAISE EXCEPTION 'Branch -> % not in programme -> %', NEW.branch,New.programme;
    END IF;
    RETURN NEW;
END
$$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS branchInProgramme ON ChosenBranch;
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
	-- REMEMBER assertion for (c1 to c2 to c1)... 
);

-- This trigger function does:
-- - check if inserting the new prerequisite create a cycle
-- - - If it does then we don't insert it
-- - - otherwise just insert
CREATE OR REPLACE FUNCTION checkCycle()
RETURNS TRIGGER AS $$
DECLARE
    arr bpchar[];
BEGIN
    -- copy table and insert new prerequisite into copy
    CREATE TEMP TABLE prereq AS SELECT * FROM Prerequisite;
    INSERT INTO prereq VALUES (NEW.prerequisite, NEW.toCourse);

    -- look for prerequisite depenencies
    IF EXISTS (
       WITH RECURSIVE prev AS (
            SELECT p.prerequisite, 
                1 AS depth, 
                arr || p.prerequisite  as seen, 
                false as cycle
            FROM prereq p
            WHERE p.prerequisite = NEW.toCourse
                UNION ALL
                    SELECT p.prerequisite, 
                        prev.depth + 1, 
                        seen || p.prerequisite as seen, 
                        p.prerequisite = any(seen) as cycle
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
        -- Detected cycle, abort
        DROP TABLE prereq;
        RAISE 'Cycle detected: % -> %', NEW.prerequisite, NEW.toCourse;
    ELSE
        -- No cycle, insert new prerequisite
        DROP TABLE prereq;
        RETURN NEW;
    END IF; 

END
$$ LANGUAGE 'plpgsql';

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

-- This trigger function does:
-- - Check that a student fulfilles the prerequisites for a course s/he wants to register on
-- - Check if the course is limited AND
-- - - that there are spots left and if so register the student.
--     Also decriments the number of free spots on the course by one.
-- - - places the student on the waiting list for that course if
--     there are no spots left
CREATE OR REPLACE FUNCTION hasClearedPrerequisites() 
RETURNS TRIGGER AS $$
DECLARE
    arr bpchar[];
BEGIN
	CREATE TEMP TABLE prereq AS 
        SELECT * FROM Prerequisite 
        WHERE NEW.course = Prerequisite.toCourse; --all prereq to intresting course
    CREATE TEMP TABLE fin AS 
        SELECT course FROM Finished 
        WHERE NEW.student = Finished.student; -- student's finished courses

    -- look up the requirements. 
    -- TODO Actually, recursive is overkill. Should just need to check
    -- requirements in one step...
    IF EXISTS (
      WITH RECURSIVE prev AS (
                SELECT p.prerequisite, 
                    arr || NEW.course || p.prerequisite AS seen, 
                    p.prerequisite IN (SELECT * FROM fin) AS qualified
                FROM Prerequisite p
                WHERE p.toCourse = NEW.course
                    UNION ALL
                        SELECT p.prerequisite, 
                            seen || p.prerequisite As seen, 
                            prev.prerequisite IN (SELECT * FROM fin) AS qualified
                        FROM prev
                        INNER JOIN Prerequisite p ON prev.prerequisite = p.toCourse
        )
        SELECT 1 
        FROM prev
        WHERE NOT qualified
        LIMIT 1
    ) 
    THEN 
        -- student doesn't fulfill the requirements for the course
        DROP TABLE IF EXISTS fin;
        DROP TABLE IF EXISTS prereq;
        RAISE 'Student % have not taken all prerequisite courses for course %', 
                NEW.student, NEW.course;
    ELSE
        DROP TABLE IF EXISTS fin;
        DROP TABLE IF EXISTS prereq;
        IF EXISTS (SELECT code FROM LimitedCourses WHERE LimitedCourses.code = NEW.course) THEN
            IF (SELECT studentLimit FROM LimitedCourses WHERE LimitedCourses.code = NEW.course) > 0 THEN
                -- decriment number of free spots by 1
                UPDATE LimitedCourses SET studentLimit = studentLimit - 1
                WHERE LimitedCourses.code = NEW.course;
                -- register
                RETURN NEW;
            ELSE
                -- No spots left on course, place in waiting list
                RAISE NOTICE 'Course "%" is full, placing student % on waiting list', NEW.course, NEW.student;
                INSERT INTO WaitingOn VALUES (NEW.course, NEW.student, CURRENT_TIME);
                RETURN NULL;
            END IF;
        ELSE
            -- register
            RETURN NEW;
        END IF;
    END IF;
END
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER check_qualifications BEFORE INSERT ON Registered
	FOR EACH ROW EXECUTE PROCEDURE hasClearedPrerequisites();

-- This trigger function increases the course limit by one after a student 
-- has been deleted, but only if the course was a limitedcourse
CREATE OR REPLACE FUNCTION correct_limit() 
RETURNS TRIGGER AS $$
DECLARE
    _waitingStudent CHAR(10);
BEGIN
    IF EXISTS (SELECT code FROM LimitedCourses WHERE LimitedCourses.code = OLD.course) THEN
        -- increment number of free spots by 1
        UPDATE LimitedCourses SET studentLimit = studentLimit + 1
        WHERE LimitedCourses.code = OLD.course;
        -- TODO check waitinglist and register student on course
        RETURN OLD; 
    END IF;
END
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER increse_limit AFTER DELETE ON Registered
    FOR EACH ROW EXECUTE PROCEDURE correct_limit();


CREATE TABLE Finished (
	student	CHAR(11) 	NOT NULL REFERENCES Students(NIN),
	course	CHAR(6) 	NOT NULL REFERENCES Courses(code),
	grade	CHAR(1) 	NOT NULL CHECK(grade IN ('U', '3', '4', '5')),
	PRIMARY KEY (student, course)
);
