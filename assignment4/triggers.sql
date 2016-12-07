--------------------------------------------------------------------------------
-- This trigger function does:
-- - check that a chosen branch actually belong to the program the student
--   is enrolled in.
--------------------------------------------------------------------------------
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

DROP TRIGGER IF EXISTS branchInProgramme ON ChosenBranch;
CREATE TRIGGER branchInProgramme BEFORE INSERT ON ChosenBranch
	FOR EACH ROW EXECUTE PROCEDURE checkBranchInProgramme();
	
--------------------------------------------------------------------------------
-- This trigger function does:
-- - check if inserting the new prerequisite create a cycle
-- - - If it does then we don't insert it
-- - - otherwise just insert
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION checkCycle()
RETURNS TRIGGER AS $$
DECLARE
    arr bpchar[];
BEGIN
	
	IF (NEW.prerequisite IS NULL) THEN
		RAISE EXCEPTION 'prerequisite cannot be null';
	ELSEIF (NEW.toCourse IS NULL) THEN
		RAISE EXCEPTION 'toCourse cannot be null';	
	END IF;
	
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

DROP TRIGGER IF EXISTS cycle ON Prerequisite;
CREATE TRIGGER cycle BEFORE INSERT ON Prerequisite
	FOR EACH ROW EXECUTE PROCEDURE checkCycle();

--------------------------------------------------------------------------------
-- This trigger function does:
-- - Check that a student fulfilles the prerequisites for a course s/he wants 
--   to register on
-- - Check if the course is limited AND
-- - - that there are spots left and if so register the student.
--     Also decriments the number of free spots on the course by one.
-- - - places the student on the waiting list for that course if
--     there are no spots left
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION hasClearedPrerequisites() 
RETURNS TRIGGER AS $$
DECLARE
    arr bpchar[];
BEGIN

	IF (NEW.student IS NULL) THEN
		RAISE EXCEPTION 'Studen cannot be null';
	ELSEIF (NEW.course IS NULL) THEN
		RAISE EXCEPTION 'Course cannot be null';	
	END IF;
	
	IF EXISTS (SELECT * FROM WaitingOn wo WHERE wo.course = NEW.course AND wo.student = NEW.student) THEN
		RAISE EXCEPTION 'Studen % is already in the waiting list for course %', NEW.student, NEW.course;
	END IF;
	
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
                INSERT INTO Registered VALUES (NEW.student, NEW.course);
                RETURN NEW;
            ELSE
                -- No spots left on course, place in waiting list
                RAISE NOTICE 'Course "%" is full, placing student % on waiting list', NEW.course, NEW.student;
                INSERT INTO WaitingOn VALUES (NEW.course, NEW.student, CURRENT_TIME);
                RETURN NULL;
            END IF;
        ELSE
            -- register
            INSERT INTO Registered VALUES (NEW.student, NEW.course);
            RETURN NEW;
        END IF;
    END IF;
END
$$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS check_qualifications ON Registrations;
CREATE TRIGGER check_qualifications INSTEAD OF INSERT ON Registrations
	FOR EACH ROW EXECUTE PROCEDURE hasClearedPrerequisites();

--------------------------------------------------------------------------------
-- This trigger function increases the course limit by one after a student 
-- has been deleted, but only if the course was a limitedcourse
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION correct_limit() 
RETURNS TRIGGER AS $$
DECLARE
    _waitingStudent CHAR(10);
BEGIN
    IF EXISTS (SELECT code FROM LimitedCourses WHERE LimitedCourses.code = OLD.course) THEN
    
    	SELECT student INTO _waitingStudent FROM CourseQueuePositions cqp
    	WHERE cqp.course = OLD.course AND cqp.position = 1 ;
    	
    	IF (_waitingStudent IS NULL) THEN
    		-- increment number of free spots by 1
		    UPDATE LimitedCourses SET studentLimit = studentLimit + 1
		    WHERE LimitedCourses.code = OLD.course;
		    
		ELSE
    		-- remove student from waiting list
    		DELETE FROM CourseQueuePositions cqp 
    		WHERE cqp.course = OLD.course AND cqp.position = 1;
    	
    		-- register waiting student on course
    		INSERT INTO Registrations VALUES (_waitingStudent, OLD.course, 'Registered');
    		
    	END IF;
    	
    END IF;
    
    -- Delete from underlying table
    DELETE FROM Registered r 
    WHERE r.student = OLD.student AND r.course = OLD.course;

    RETURN OLD;
    
END
$$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS increse_limit ON Registrations;
CREATE TRIGGER increse_limit INSTEAD OF DELETE ON Registrations
    FOR EACH ROW EXECUTE PROCEDURE correct_limit();



