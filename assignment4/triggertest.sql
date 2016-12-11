CREATE OR REPLACE FUNCTION test_main() RETURNS TEXT AS $$
BEGIN

RAISE NOTICE '<-------------------- Initialize test suite -------------------->';

RETURN 'Proceeding to add test data';

END
$$ LANGUAGE 'plpgsql';
SELECT test_main();


    -- branches for students 
    INSERT INTO ChosenBranch (student,branch,programme) VALUES ('9008150001','Branch1','Programme1');
    INSERT INTO ChosenBranch (student,branch,programme) VALUES ('9008150002','Branch2','Programme2');
    INSERT INTO ChosenBranch (student,branch,programme) VALUES ('9008150003','Branch3','Programme3');
    INSERT INTO ChosenBranch (student,branch,programme) VALUES ('9008150004','Branch4','Programme4');
    INSERT INTO ChosenBranch (student,branch,programme) VALUES ('9008150005','Branch5','Programme5');
    INSERT INTO ChosenBranch (student,branch,programme) VALUES ('9008150006','Branch6','Programme6');
    --INSERT INTO ChosenBranch (student,branch,programme) VALUES ('9008150007','Branch1','Programme7');
    INSERT INTO ChosenBranch (student,branch,programme) VALUES ('9008150008','Branch2','Programme8');
    INSERT INTO ChosenBranch (student,branch,programme) VALUES ('9008150009','Branch3','Programme9');
    INSERT INTO ChosenBranch (student,branch,programme) VALUES ('9008150010','Branch4','Programme10');
    --INSERT INTO ChosenBranch (student,branch,programme) VALUES ('9008150011','Branch5','Programme1');
    INSERT INTO ChosenBranch (student,branch,programme) VALUES ('9008150012','Branch6','Programme2');
    --INSERT INTO ChosenBranch (student,branch,programme) VALUES ('9008150013','Branch5','Programme1');
    INSERT INTO ChosenBranch (student,branch,programme) VALUES ('9008150014','Branch2','Programme2');

    -- prerequisites for courses
    INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA001','TDA003');
    INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA001','TDA004');
    INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA003','TDA006');
    INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA004','TDA006');
    INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA014','TDA003');
    INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA013','TDA015');
    INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA002','TDA009');
    INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA011','TDA016');


    -- registrations 
    -- 5 regesitered students and 4 waiting students on course TDA009
    INSERT INTO Registrations (student, course) VALUES ('9008150001', 'TDA009');
    INSERT INTO Registrations (student, course) VALUES ('9008150002', 'TDA009');
    INSERT INTO Registrations (student, course) VALUES ('9008150003', 'TDA009');
    INSERT INTO Registrations (student, course) VALUES ('9008150004', 'TDA009');
    INSERT INTO Registrations (student, course) VALUES ('9008150005', 'TDA009');
    INSERT INTO Registrations (student, course) VALUES ('9008150006', 'TDA009'); -- waiting
    INSERT INTO Registrations (student, course) VALUES ('9008150007', 'TDA009'); -- waiting
    INSERT INTO Registrations (student, course) VALUES ('9008150008', 'TDA009'); -- waiting
    INSERT INTO Registrations (student, course) VALUES ('9008150009', 'TDA009'); -- waiting


   -- 3 regesitered students and 4 waiting students on course TDA008
    INSERT INTO Registrations (student, course) VALUES ('9008150003', 'TDA008');
    INSERT INTO Registrations (student, course) VALUES ('9008150004', 'TDA008');
    INSERT INTO Registrations (student, course) VALUES ('9008150005', 'TDA008');
    INSERT INTO Registrations (student, course) VALUES ('9008150006', 'TDA008'); -- waiting
    INSERT INTO Registrations (student, course) VALUES ('9008150007', 'TDA008'); -- waiting
    INSERT INTO Registrations (student, course) VALUES ('9008150008', 'TDA008'); -- waiting
    INSERT INTO Registrations (student, course) VALUES ('9008150015', 'TDA008'); -- waiting

    INSERT INTO Registrations (student, course) VALUES ('9008150009', 'TDA014');
    INSERT INTO Registrations (student, course) VALUES ('9008150015', 'TDA010');





-- CREATE OR REPLACE FUNCTION test_template() RETURNS TEXT AS $$
-- BEGIN

-- RAISE NOTICE '<--------------------------- New Test --------------------------->';
-- RAISE NOTICE '--> Attempt to ...';
--     INSERT INTO table VALUES (a, b, c, ...);
--     RETURN 'Fail';
-- EXCEPTION 
--     WHEN raise_exception THEN 
--         RAISE NOTICE 'Caught exception';
--         RETURN 'Done';

-- END
-- $$ LANGUAGE 'plpgsql';
-- SELECT test_template();


CREATE OR REPLACE FUNCTION test_info() RETURNS TEXT AS $$
BEGIN

RAISE NOTICE '<------------------------ Starting Tests ------------------------>';

RETURN 'Proceeding to run the tests';

END
$$ LANGUAGE 'plpgsql';
SELECT test_info();

--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION test_branches() RETURNS TEXT AS $$
BEGIN

RAISE NOTICE '<--------------------------- New Test --------------------------->';
RAISE NOTICE '--> Have student attempt to choose branch from another program';    
    INSERT INTO ChosenBranch (student,branch,programme) VALUES ('9008150015','Branch2','Programme1');
    RETURN 'Fail';
EXCEPTION 
    WHEN raise_exception THEN 
        RAISE NOTICE 'Caught exception';
        RAISE NOTICE 'Student was not able to choose a branch outside his programme';
        RETURN 'Done';
END
$$ LANGUAGE 'plpgsql';
SELECT test_branches();

--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION test_prerequisites() RETURNS TEXT AS $$
BEGIN

RAISE NOTICE '<--------------------------- New Test --------------------------->';
RAISE NOTICE '--> Attempt to add a prerequisite which would create a cycle';  
    INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA006','TDA001');
    RETURN 'Fail';
EXCEPTION 
    WHEN raise_exception THEN 
        RAISE NOTICE 'Caught exception';
        RAISE NOTICE 'Unable to add prerequisite which would create a cycle';
        RETURN 'Done';
END
$$ LANGUAGE 'plpgsql';
SELECT test_prerequisites();


--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION test_re_register() RETURNS TEXT AS $$
BEGIN

RAISE NOTICE '<--------------------------- New Test --------------------------->';
RAISE NOTICE '--> Attempt to re-register students on courses';
    INSERT INTO Registrations (student, course) VALUES ('9008150001', 'TDA009');
    RETURN 'Fail';
EXCEPTION 
    WHEN raise_exception THEN 
        RAISE NOTICE 'Caught exception';
        RAISE NOTICE 'Student was not able to register twice on a course';
        RETURN 'Done';

END
$$ LANGUAGE 'plpgsql';
SELECT test_re_register();


--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION test_register_no_qual() RETURNS TEXT AS $$
BEGIN

RAISE NOTICE '<--------------------------- New Test --------------------------->';
RAISE NOTICE '--> Attempt to register without qualifications';
    INSERT INTO Registrations (student, course) VALUES ('9008150005', 'TDA003');
    RETURN 'Fail';
EXCEPTION 
    WHEN raise_exception THEN 
        RAISE NOTICE 'Caught exception';
        RAISE NOTICE 'Student was unable to register without qualifications';
        RETURN 'Done';

END
$$ LANGUAGE 'plpgsql';
SELECT test_register_no_qual();

--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION test_register_failed_prereq() RETURNS TEXT AS $$
BEGIN

RAISE NOTICE '<--------------------------- New Test --------------------------->';
RAISE NOTICE '--> Attempt to register with failed prerequisite';
    INSERT INTO Registrations (student, course) VALUES ('9008150015', 'TDA016');
    RETURN 'Fail';
EXCEPTION 
    WHEN raise_exception THEN 
        RAISE NOTICE 'Caught exception';
        RAISE NOTICE 'Student was unable to register without qualifications';
        RETURN 'Done';

END
$$ LANGUAGE 'plpgsql';
SELECT test_register_failed_prereq();


--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION test_unregister_twice() RETURNS TEXT AS $$
BEGIN

RAISE NOTICE '<--------------------------- New Test --------------------------->';
RAISE NOTICE '--> Attempt to unregister from courses twice';

    DELETE FROM Registrations r 
    WHERE r.student = '9008150001' AND r.course = 'TDA009';

    DELETE FROM Registrations r 
    WHERE r.student = '9008150001' AND r.course = 'TDA009';

    IF EXISTS (SELECT * FROM Registrations r WHERE
            r.student = '9008150001' AND r.course = 'TDA009') THEN

        RAISE NOTICE 'Student is still registered';
        RETURN 'Fail';

    ELSE

        RAISE NOTICE 'Student is still unregistered';
        RETURN 'Done';

    END IF;

EXCEPTION 
    WHEN raise_exception THEN 
        RAISE NOTICE 'Unexpected exception';
        RETURN 'Fail';
END
$$ LANGUAGE 'plpgsql';
SELECT test_unregister_twice();


--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION test_unregister_with_queue() RETURNS TEXT AS $$
DECLARE
    _fstStudent CHAR(10);
    _sndStudent CHAR(10);
BEGIN
RAISE NOTICE '<--------------------------- New Test --------------------------->';
RAISE NOTICE '--> Unregister a student when there are students waitning';

    SELECT student INTO _fstStudent FROM CourseQueuePositions cqp
    WHERE cqp.course = 'TDA008' AND cqp.position = 1;

    SELECT student INTO _sndStudent FROM CourseQueuePositions cqp
    WHERE cqp.course = 'TDA008' AND cqp.position = 2;

    DELETE FROM Registrations r WHERE r.student = '9008150004' AND r.course = 'TDA008';

    IF ((SELECT position FROM CourseQueuePositions cqp 
        WHERE  cqp.course = 'TDA008' AND cqp.student = _sndStudent) <> 1) 
        OR NOT EXISTS (SELECT * FROM Registrations r 
                    WHERE r.student = _fstStudent AND r.course = 'TDA008') THEN

        RAISE NOTICE 'Student were given wrong position or were not reged properly';
        RETURN 'Fail';
    ELSE

        RAISE NOTICE 'Student was unregistered and student from waiting list was registered';
        RETURN 'Done';
    END IF;

EXCEPTION 
    WHEN raise_exception THEN 
        RAISE NOTICE 'unexpected exception';
        RETURN 'Fail';

END
$$ LANGUAGE 'plpgsql';
SELECT test_unregister_with_queue();


--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION test_unreg_reg_wait() RETURNS TEXT AS $$
DECLARE
    _lastPos INT;
BEGIN

RAISE NOTICE '<--------------------------- New Test --------------------------->';
RAISE NOTICE '--> Unregister, then register student on limited course';

    SELECT position INTO _lastPos 
    FROM CourseQueuePositions cqp 
    WHERE cqp.course = 'TDA009' 
        AND cqp.position = (
            SELECT MAX(position) 
            FROM CourseQueuePositions cqp 
            WHERE cqp.course = 'TDA009');

    RAISE NOTICE '#Students waiting for course TDA009 is %', 
                CAST(_lastPos AS TEXT);

    DELETE FROM Registrations r WHERE r.student = '9008150002' AND r.course = 'TDA009';
    INSERT INTO Registrations (student, course) VALUES ('9008150002', 'TDA009');

    IF (SELECT position FROM CourseQueuePositions cqp 
        WHERE cqp.course = 'TDA009' 
        AND cqp.student = '9008150002') <> _lastPos THEN


        SELECT position INTO _lastPos 
            FROM CourseQueuePositions cqp 
            WHERE cqp.course = 'TDA009' 
                AND cqp.student = '9008150002';

        RAISE NOTICE 'student was given position %, which is incorrect', 
                        CAST(_lastPos AS TEXT);
        RETURN 'Fail';
    
    ELSE

        RAISE NOTICE 'Student received the correct position';
        RETURN 'Done';
    
    END IF;

EXCEPTION 
    WHEN raise_exception THEN 
        RAISE NOTICE 'unexpected exception';
        RETURN 'Fail';

END
$$ LANGUAGE 'plpgsql';
SELECT test_unreg_reg_wait();


--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION test_reg_unreg_reg_wait() RETURNS TEXT AS $$
DECLARE
    _pos INT;
BEGIN

RAISE NOTICE '<--------------------------- New Test --------------------------->';
RAISE NOTICE '--> Register, unregister, and then register student on limited course';


    INSERT INTO Registrations VALUES ('9008150010', 'TDA008'); -- waiting

    SELECT Position INTO _pos FROM CourseQueuePositions cqp
    WHERE cqp.student = '9008150010' AND cqp.course = 'TDA008';

    IF (SELECT MAX(position) FROM CourseQueuePositions cqp
        WHERE cqp.course = 'TDA008') <> _pos THEN

        RAISE NOTICE 'Student recieved the wrong position';
        RETURN 'Fail';

    ELSE 

        DELETE FROM Registrations
        WHERE student = '9008150010' AND course = 'TDA008';

        IF EXISTS (SELECT * FROM CourseQueuePositions WHERE
                    student = '9008150010' AND course = 'TDA008') THEN

            RAISE NOTICE 'Student remains in queue, even though unregistered';
            RETURN 'Fail';

        ELSE

            INSERT INTO Registrations VALUES ('9008150010', 'TDA008');

            IF (SELECT position FROM CourseQueuePositions cqp
                WHERE cqp.course = 'TDA008' 
                AND cqp.student = '9008150010') <> _pos THEN
                
                RAISE NOTICE 'Student recieved the wrong position';
                RETURN 'Fail';

            ELSE

                RAISE NOTICE 'Student received the correct position';
                RETURN 'Done';

            END IF;

        END IF;

    END IF;

EXCEPTION 
    WHEN raise_exception THEN 
        RAISE NOTICE 'unexpected exception';
        RETURN 'Fail';

END
$$ LANGUAGE 'plpgsql';
SELECT test_reg_unreg_reg_wait();


--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION test_unregister_overfull() RETURNS TEXT AS $$
DECLARE
    _size int;
BEGIN
RAISE NOTICE '<--------------------------- New Test --------------------------->';
RAISE NOTICE '--> Test to unregister a student when there are students waiting on an overfull course';

    RAISE NOTICE 'Adding more students to TDA009, making it overfull';
    INSERT INTO Registered (student, course) VALUES ('9008150014', 'TDA009');
    INSERT INTO Registered (student, course) VALUES ('9008150015', 'TDA009');

    CREATE TEMP TABLE copy AS (SELECT * FROM CourseQueuePositions);

    DELETE FROM Registered WHERE student = '9008150003' AND course = 'TDA009'; 


    IF (SELECT COUNT(1)
        FROM copy FULL OUTER JOIN CourseQueuePositions cqp 
        USING (student, course)
        WHERE copy.student IS NULL OR cqp.student IS NULL
    ) THEN
        
        RAISE NOTICE 'CourseQueuePositions has changed!';
        DROP TABLE IF EXISTS copy;
        RETURN 'Fail';
    ELSE
        RAISE NOTICE 'Student unregistered, waiting list is untouched';
        DROP TABLE IF EXISTS copy;
        RETURN 'Done';
    END IF;

EXCEPTION 
    WHEN raise_exception THEN 
        RAISE NOTICE 'unexpected exception';
        RETURN 'Fail';

END
$$ LANGUAGE 'plpgsql';
SELECT test_unregister_overfull();
