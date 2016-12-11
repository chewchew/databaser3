
PRINT 'ello';

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
-- should fail
-- INSERT INTO ChosenBranch (student,branch,programme) VALUES ('9008150015','Branch2','Programme1');

INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA001','TDA003');
INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA001','TDA004');
INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA003','TDA006');
INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA004','TDA006');
INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA014','TDA003');
INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA013','TDA015');
INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA002','TDA009');
-- should fail
--INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA006','TDA001');

-- 5 regesitered students and 3 waiting students on course TDA009
INSERT INTO Registrations (student, course) VALUES ('9008150001', 'TDA009');
INSERT INTO Registrations (student, course) VALUES ('9008150002', 'TDA009');
INSERT INTO Registrations (student, course) VALUES ('9008150003', 'TDA009');
INSERT INTO Registrations (student, course) VALUES ('9008150004', 'TDA009');
INSERT INTO Registrations (student, course) VALUES ('9008150005', 'TDA009');
INSERT INTO Registrations (student, course) VALUES ('9008150006', 'TDA009'); -- waiting
INSERT INTO Registrations (student, course) VALUES ('9008150007', 'TDA009'); -- waiting
INSERT INTO Registrations (student, course) VALUES ('9008150008', 'TDA009'); -- waiting

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


-- need to check: update queue pos when  removing from wlist

-- should fail since student only on wlist and not registered
DELETE FROM Registrations r WHERE r.student = '9008150015' AND r.course = 'TDA008'; 

-- should succed
SELECT * FROM CourseQueuePositions;
DELETE FROM Registrations r WHERE r.student = '9008150004' AND r.course = 'TDA008';  
SELECT * FROM CourseQueuePositions;

-- Check tha student 6 is now registered on course 8 and has been removed from WL
-- only 3 students now wait for course 8


-- -- register on a finished course, should fail
-- INSERT INTO Registrations (student, course) VALUES ('9008150001', 'TDA011');

-- CREATE OR REPLACE FUNCTION ello() RETURNS VOID AS $$
-- BEGIN
--     RAISE NOTICE 'ello';
-- END;
-- $$ LANGUAGE 'plpqsql';


-- CALL ello();