DROP VIEW IF EXISTS CourseQueuePositions;
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

------------------------------------ Tables ------------------------------------
CREATE TABLE Departments (
    name            TEXT    NOT NULL PRIMARY KEY,
    abbreviation    TEXT    NOT NULL UNIQUE
);

CREATE TABLE Programmes (
    name            TEXT    NOT NULL PRIMARY KEY,
    abbreviation    TEXT    NOT NULL
);

CREATE TABLE HostedBy (
    programme       TEXT    NOT NULL,
    department      TEXT    NOT NULL REFERENCES Departments(name),
    FOREIGN KEY (programme) REFERENCES Programmes(name),
    PRIMARY KEY (programme,department)
);

CREATE TABLE Branches (
    name            TEXT    NOT NULL,
    programme       TEXT    NOT NULL,
    FOREIGN KEY (programme) REFERENCES Programmes(name),
    PRIMARY KEY (name,programme)
);

CREATE TABLE Students (
    NIN             CHAR(10)    NOT NULL PRIMARY KEY,
    name            TEXT        NOT NULL,
    loginID         TEXT        NOT NULL UNIQUE,
    programme       TEXT        NOT NULL REFERENCES Programmes(name)
);

CREATE TABLE ChosenBranch (
    student         CHAR(10)    NOT NULL REFERENCES Students(NIN) PRIMARY KEY,
    branch          TEXT        NOT NULL,
    programme       TEXT        NOT NULL
);

CREATE TABLE Courses (
    code        CHAR(6) NOT NULL PRIMARY KEY,
    name        TEXT NOT NULL,
    credits     REAL NOT NULL,
    department  TEXT NOT NULL REFERENCES Departments(name)
);

CREATE TABLE LimitedCourses (
    code            CHAR(6) NOT NULL REFERENCES Courses(code) PRIMARY KEY,
    studentLimit    INT     NOT NULL CHECK(studentLimit >= 0)
);

CREATE TABLE Classifications (
    class   TEXT NOT NULL PRIMARY KEY
);

CREATE TABLE HasClass (
    course  CHAR(6) NOT NULL REFERENCES Courses(code),
    class   TEXT    NOT NULL REFERENCES Classifications(class),
    PRIMARY KEY (course, class)
);

CREATE TABLE WaitingOn (
    course  CHAR(6)     NOT NULL REFERENCES LimitedCourses(code),
    student CHAR(11)    NOT NULL REFERENCES Students(NIN),
    date    TIME        NOT NULL UNIQUE,
    PRIMARY KEY (course, student)
);

CREATE TABLE Prerequisite (
    prerequisite    CHAR(6) NOT NULL REFERENCES Courses(code),
    toCourse        CHAR(6) NOT NULL REFERENCES Courses(code),
    PRIMARY KEY (prerequisite, toCourse),
    CHECK(NOT (prerequisite = toCourse))
);

CREATE TABLE ProgrammeMandatory (
    programme   TEXT    NOT NULL REFERENCES Programmes(name),
    course      CHAR(6) NOT NULL REFERENCES Courses(code),
    PRIMARY KEY (programme, course)
);

CREATE TABLE BranchMandatory (
    branch      TEXT    NOT NULL,
    programme   TEXT    NOT NULL,
    course      CHAR(6) NOT NULL REFERENCES Courses(code),
    FOREIGN KEY (branch,programme) REFERENCES Branches(name,programme),
    PRIMARY KEY (programme, branch, course)
);

CREATE TABLE Recommended (
    branch      TEXT    NOT NULL,
    programme   TEXT    NOT NULL,
    course      CHAR(6) NOT NULL REFERENCES Courses(code),
    FOREIGN KEY (branch,programme) REFERENCES Branches(name,programme),
    PRIMARY KEY (programme, branch, course)
);

CREATE TABLE Registered (
    student CHAR(11)    NOT NULL REFERENCES Students(NIN),
    course  CHAR(6)     NOT NULL REFERENCES Courses(code),
    PRIMARY KEY (student, course)
);

CREATE TABLE Finished (
    student CHAR(11)    NOT NULL REFERENCES Students(NIN),
    course  CHAR(6)     NOT NULL REFERENCES Courses(code),
    grade   CHAR(1)     NOT NULL CHECK(grade IN ('U', '3', '4', '5')),
    PRIMARY KEY (student, course)
);


------------------------------------ Views ------------------------------------

-- StudentsFollowing
-- For all students, their basic information (name etc.), and the programme and branch (if any) they are following.
DROP VIEW IF EXISTS StudentsFollowing;
CREATE VIEW StudentsFollowing AS
    SELECT Students.NIN, Students.name, Students.programme, ChosenBranch.branch FROM Students JOIN ChosenBranch ON Students.NIN = ChosenBranch.student;

-- FinishedCourses
-- For all students, all finished courses, along with their names, grades (grade 'U', '3', '4' or '5') and number of credits.
DROP VIEW IF EXISTS FinishedCourses;
CREATE VIEW FinishedCourses AS
    SELECT Students.NIN AS StudentNIN, Students.name AS StudentName, Finished.grade, Courses.code AS Course, Courses.credits 
        FROM Students JOIN Finished ON Students.NIN = Finished.student 
            JOIN Courses ON Finished.course = Courses.code;

-- Registrations
-- All registered and waiting students for all courses, along with their waiting status ('registered' or 'waiting').
DROP VIEW IF EXISTS Registrations;
CREATE VIEW Registrations AS
    SELECT Students.NIN AS Student, C.course AS Course, 
        CASE WHEN (Student,Course) IN (SELECT student,course FROM WaitingOn) THEN 'WaitingOn' ELSE 'Registered' END AS Status
        FROM Students NATURAL JOIN
            ((SELECT * FROM Students JOIN Registered ON Students.NIN = Registered.student) AS A
                        NATURAL FULL JOIN (SELECT * FROM Students JOIN WaitingOn ON Students.NIN = WaitingOn.student) AS B) AS C;
            
-- PassedCourses
-- For all students, all passed courses, i.e. courses finished with a 
-- grade other than ‘U’, and the number of credits for those courses. 
-- This view is intended as a helper view towards the PathToGraduation
-- view (and for task 4), and will not be directly used by your application.
DROP VIEW IF EXISTS PassedCourses CASCADE;
CREATE VIEW PassedCourses AS
    SELECT NIN, course, grade, credits FROM
        Courses JOIN
            (Students JOIN Finished 
                ON Students.NIN = Finished.student AND Finished.grade IN ('3','4','5')) 
            AS A
        ON Courses.code = A.course;

-- UnreadMandatory
-- For all students, the mandatory courses (branch and programme) they 
-- have not yet passed. This view is intended as a helper view towards 
-- the PathToGraduation view, and will not be directly used by your application.
DROP VIEW IF EXISTS UnreadMandatory;
CREATE VIEW UnreadMandatory AS
    SELECT Students.NIN, A.course FROM
        (SELECT programme,course FROM ProgrammeMandatory UNION SELECT programme,course from BranchMandatory) AS A
    JOIN
        Students ON A.programme = Students.programme AND 
            (Students.NIN,A.course) NOT IN (SELECT NIN,course FROM PassedCourses)
    ORDER BY NIN;

-- PathToGraduation
-- For all students, their path to graduation, i.e. a view with columns for
-- - the number of credits they have taken.
-- - the number of mandatory courses they have yet to read (branch or programme).
-- - the number of credits they have taken in courses that are classified as math courses.
-- - the number of credits they have taken in courses that are classified as research courses.
-- - the number of seminar courses they have read.
-- whether or not they qualify for graduation.
--      10hp recommended branch
--      20hp math
--      10hp research
--      1 seminar course
DROP VIEW IF EXISTS PathToGraduation;
CREATE VIEW PathToGraduation AS
    SELECT 
        Passed.NIN, 
        CollectedCredits, 
        CASE WHEN UnreadCourses IS NULL THEN 0 ELSE UnreadCourses END,
        CASE WHEN MathCredits IS NULL THEN 0 ELSE MathCredits END,
        CASE WHEN ResearchCredits IS NULL THEN 0 ELSE ResearchCredits END,
        CASE WHEN ReadSeminarCourses IS NULL THEN 0 ELSE ReadSeminarCourses END,
        CASE WHEN 
            UnreadCourses IS NULL AND 
            MathCredits >= 20 AND
            ResearchCredits >= 10 AND
            ReadSeminarCourses > 0 AND
            CollectedRecommendedCredits >= 10
            THEN 'Does Qualify'
            ELSE 'Does Not Qualify'
        END AS Graduation
    FROM
    (SELECT NIN,SUM(credits) AS CollectedCredits 
        FROM PassedCourses 
        GROUP BY NIN) AS Passed
    LEFT OUTER JOIN
    (SELECT NIN,SUM(credits) AS CollectedRecommendedCredits 
        FROM PassedCourses 
        WHERE PassedCourses.course IN
            (SELECT course 
                FROM Recommended
                WHERE Recommended.programme IN
                    (SELECT programme FROM Students WHERE Students.NIN = NIN))
        GROUP BY NIN) AS PassedRecommended
    ON Passed.NIN = PassedRecommended.NIN
    LEFT OUTER JOIN
    (SELECT NIN,COUNT(course) AS UnreadCourses
        FROM UnreadMandatory
        GROUP BY NIN) AS Unread
    ON Passed.NIN = Unread.NIN
    LEFT OUTER JOIN
    (SELECT NIN,SUM(credits) AS MathCredits
        FROM HasClass JOIN PassedCourses
        ON HasClass.course = PassedCourses.course AND HasClass.class = 'Math'
        GROUP BY NIN) AS PassedMath
    ON Passed.NIN = PassedMath.NIN
    LEFT OUTER JOIN
    (SELECT NIN,SUM(credits) AS ResearchCredits
        FROM HasClass JOIN PassedCourses
        ON HasClass.course = PassedCourses.course AND HasClass.class = 'Research'
        GROUP BY NIN) AS PassedResearch
    ON Passed.NIN = PassedResearch.NIN
    LEFT OUTER JOIN
    (SELECT NIN,COUNT(credits) AS ReadSeminarCourses
        FROM HasClass JOIN PassedCourses
        ON HasClass.course = PassedCourses.course AND HasClass.class = 'Seminar'
        GROUP BY NIN) AS ReadSeminar
    ON Passed.NIN = ReadSeminar.NIN;

-- CourseQueuePositions
-- For all students who are in the queue for a course, the course code, 
-- he student’s identification number, and the student’s current place 
-- in the queue (the student who is first in a queue will have place 
-- “1” in that queue, etc.).
DROP VIEW IF EXISTS CourseQueuePositions;
CREATE VIEW CourseQueuePositions AS
    SELECT student, course, rank() over (PARTITION BY course ORDER BY date asc) AS position
    FROM WaitingOn;

---------------------------------- Test Data ----------------------------------

-- Departments
INSERT INTO Departments (name,abbreviation) VALUES ('Department1','D1');
INSERT INTO Departments (name,abbreviation) VALUES ('Department2','D2');
INSERT INTO Departments (name,abbreviation) VALUES ('Department3','D3');
INSERT INTO Departments (name,abbreviation) VALUES ('Department4','D4');
INSERT INTO Departments (name,abbreviation) VALUES ('Department5','D5');
INSERT INTO Departments (name,abbreviation) VALUES ('Department6','D6');

-- Programmes
INSERT INTO Programmes (name,abbreviation) VALUES ('Programme1' ,'P1');
INSERT INTO Programmes (name,abbreviation) VALUES ('Programme2' ,'P2');
INSERT INTO Programmes (name,abbreviation) VALUES ('Programme3' ,'P3');
INSERT INTO Programmes (name,abbreviation) VALUES ('Programme4' ,'P4');
INSERT INTO Programmes (name,abbreviation) VALUES ('Programme5' ,'P5');
INSERT INTO Programmes (name,abbreviation) VALUES ('Programme6' ,'P6');
INSERT INTO Programmes (name,abbreviation) VALUES ('Programme7' ,'P7');
INSERT INTO Programmes (name,abbreviation) VALUES ('Programme8' ,'P8');
INSERT INTO Programmes (name,abbreviation) VALUES ('Programme9' ,'P9');
INSERT INTO Programmes (name,abbreviation) VALUES ('Programme10','P10');

-- Programes hosted by departments
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

-- Branches in programmes
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

-- Students
INSERT INTO Students (NIN,name,loginID,programme) VALUES ('9008150001','Name1','loginId1','Programme1');
INSERT INTO Students (NIN,name,loginID,programme) VALUES ('9008150002','Name2','loginId2','Programme2');
INSERT INTO Students (NIN,name,loginID,programme) VALUES ('9008150003','Name3','loginId3','Programme3');
INSERT INTO Students (NIN,name,loginID,programme) VALUES ('9008150004','Name4','loginId4','Programme4');
INSERT INTO Students (NIN,name,loginID,programme) VALUES ('9008150005','Name5','loginId5','Programme5');
INSERT INTO Students (NIN,name,loginID,programme) VALUES ('9008150006','Name6','loginId6','Programme6');
INSERT INTO Students (NIN,name,loginID,programme) VALUES ('9008150007','Name7','loginId7','Programme7');
INSERT INTO Students (NIN,name,loginID,programme) VALUES ('9008150008','Name8','loginId8','Programme8');
INSERT INTO Students (NIN,name,loginID,programme) VALUES ('9008150009','Name9','loginId9','Programme9');
INSERT INTO Students (NIN,name,loginID,programme) VALUES ('9008150010','Name10','loginId10','Programme10');
INSERT INTO Students (NIN,name,loginID,programme) VALUES ('9008150011','Name11','loginId11','Programme1');
INSERT INTO Students (NIN,name,loginID,programme) VALUES ('9008150012','Name12','loginId12','Programme2');
INSERT INTO Students (NIN,name,loginID,programme) VALUES ('9008150013','Name13','loginId13','Programme1');
INSERT INTO Students (NIN,name,loginID,programme) VALUES ('9008150014','Name14','loginId14','Programme2');
INSERT INTO Students (NIN,name,loginID,programme) VALUES ('9008150015','Name15','loginId15','Programme1');

-- Courses
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA001','Databases',7.5,'Department1');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA002','Treehugging 101',7.5,'Department2');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA003','Snails and Their Mating Habits',7.5,'Department3');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA004','Course4',7.5,'Department4');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA005','Advanced Robotics',7.5,'Department5');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA006','Math for Dummies',7.5,'Department6');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA007','Course7',7.5,'Department1');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA008','Functional Programming',7.5,'Department2');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA009','Course9',7.5,'Department3');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA010','Counting Stars',7.5,'Department4');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA011','Course11',7.5,'Department5');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA012','Course12',7.5,'Department6');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA013','Casino Science',7.5,'Department1');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA014','Course14',7.5,'Department2');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA015','One Grain of Sand, two...',7.5,'Department3');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA016','Course16',7.5,'Department4');

-- Courses with student limit
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA001',101);
--INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA002',102);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA003',130);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA004',104);
--INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA005',105);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA006',106);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA007',107);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA008',3);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA009',5);
--INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA010',101);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA011',102);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA012',103);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA013',104);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA014',105);
--INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA015',110);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA016',120);

-- student 1, ready for graduation
INSERT INTO Finished (student,course,grade) VALUES ('9008150001','TDA011','4');
INSERT INTO Finished (student,course,grade) VALUES ('9008150001','TDA016','3');
INSERT INTO Finished (student,course,grade) VALUES ('9008150001','TDA001','5');
INSERT INTO Finished (student,course,grade) VALUES ('9008150001','TDA014','3');
INSERT INTO Finished (student,course,grade) VALUES ('9008150001','TDA005','5');
INSERT INTO Finished (student,course,grade) VALUES ('9008150001','TDA010','5');
INSERT INTO Finished (student,course,grade) VALUES ('9008150001','TDA007','4');
INSERT INTO Finished (student,course,grade) VALUES ('9008150001','TDA003','3');
INSERT INTO Finished (student,course,grade) VALUES ('9008150001','TDA013','4');
INSERT INTO Finished (student,course,grade) VALUES ('9008150001','TDA015','3');


-- student 15, registred on mand course TDA010, waiting on TDA008
INSERT INTO Finished (student,course,grade) VALUES ('9008150015','TDA011','U');
INSERT INTO Finished (student,course,grade) VALUES ('9008150015','TDA016','3');
INSERT INTO Finished (student,course,grade) VALUES ('9008150015','TDA001','5');
INSERT INTO Finished (student,course,grade) VALUES ('9008150015','TDA014','3');
--INSERT INTO Finished (student,course,grade) VALUES ('9008150015','TDA010','5');
INSERT INTO Finished (student,course,grade) VALUES ('9008150015','TDA007','4');
INSERT INTO Finished (student,course,grade) VALUES ('9008150005','TDA013','4');

-- student 1 to 10 have finished TDA002, which is a prereq to TDA009
INSERT INTO Finished (student, course, grade) VALUES ('9008150001', 'TDA002', '3');
INSERT INTO Finished (student, course, grade) VALUES ('9008150002', 'TDA002', '4');
INSERT INTO Finished (student, course, grade) VALUES ('9008150003', 'TDA002', '4');
INSERT INTO Finished (student, course, grade) VALUES ('9008150004', 'TDA002', '3');
INSERT INTO Finished (student, course, grade) VALUES ('9008150005', 'TDA002', '5');
INSERT INTO Finished (student, course, grade) VALUES ('9008150006', 'TDA002', '5');
INSERT INTO Finished (student, course, grade) VALUES ('9008150007', 'TDA002', '4');
INSERT INTO Finished (student, course, grade) VALUES ('9008150008', 'TDA002', '5');
INSERT INTO Finished (student, course, grade) VALUES ('9008150009', 'TDA002', '5');
INSERT INTO Finished (student, course, grade) VALUES ('9008150010', 'TDA002', '3');

-- Mandatory courses for programmes
INSERT INTO ProgrammeMandatory (programme, course) VALUES ('Programme1', 'TDA011');
INSERT INTO ProgrammeMandatory (programme, course) VALUES ('Programme1', 'TDA016');
INSERT INTO ProgrammeMandatory (programme, course) VALUES ('Programme1', 'TDA005');
INSERT INTO ProgrammeMandatory (programme, course) VALUES ('Programme2', 'TDA001');
INSERT INTO ProgrammeMandatory (programme, course) VALUES ('Programme2', 'TDA011');
INSERT INTO ProgrammeMandatory (programme, course) VALUES ('Programme3', 'TDA001');
INSERT INTO ProgrammeMandatory (programme, course) VALUES ('Programme3', 'TDA015');
INSERT INTO ProgrammeMandatory (programme, course) VALUES ('Programme4', 'TDA003');
INSERT INTO ProgrammeMandatory (programme, course) VALUES ('Programme5', 'TDA013');
INSERT INTO ProgrammeMandatory (programme, course) VALUES ('Programme5', 'TDA006');
INSERT INTO ProgrammeMandatory (programme, course) VALUES ('Programme7', 'TDA011');
INSERT INTO ProgrammeMandatory (programme, course) VALUES ('Programme7', 'TDA007');
INSERT INTO ProgrammeMandatory (programme, course) VALUES ('Programme7', 'TDA010');

-- Mandatory courses for branches
INSERT INTO BranchMandatory (branch, programme, course) VALUES ('Branch1', 'Programme1', 'TDA001');
INSERT INTO BranchMandatory (branch, programme, course) VALUES ('Branch1', 'Programme1', 'TDA014');
INSERT INTO BranchMandatory (branch, programme, course) VALUES ('Branch1', 'Programme1', 'TDA010');
INSERT INTO BranchMandatory (branch, programme, course) VALUES ('Branch5', 'Programme1', 'TDA010');
INSERT INTO BranchMandatory (branch, programme, course) VALUES ('Branch6', 'Programme2', 'TDA016');
INSERT INTO BranchMandatory (branch, programme, course) VALUES ('Branch3', 'Programme3', 'TDA011');
INSERT INTO BranchMandatory (branch, programme, course) VALUES ('Branch4', 'Programme4', 'TDA012');
INSERT INTO BranchMandatory (branch, programme, course) VALUES ('Branch5', 'Programme5', 'TDA008');
INSERT INTO BranchMandatory (branch, programme, course) VALUES ('Branch6', 'Programme6', 'TDA002');
INSERT INTO BranchMandatory (branch, programme, course) VALUES ('Branch1', 'Programme7', 'TDA001');

INSERT INTO Recommended (branch, programme, course) VALUES ('Branch1', 'Programme1', 'TDA014');
INSERT INTO Recommended (branch, programme, course) VALUES ('Branch1', 'Programme1', 'TDA002');
INSERT INTO Recommended (branch, programme, course) VALUES ('Branch2', 'Programme2', 'TDA014');
INSERT INTO Recommended (branch, programme, course) VALUES ('Branch3', 'Programme3', 'TDA010');
INSERT INTO Recommended (branch, programme, course) VALUES ('Branch4', 'Programme4', 'TDA010');
INSERT INTO Recommended (branch, programme, course) VALUES ('Branch5', 'Programme5', 'TDA016');
INSERT INTO Recommended (branch, programme, course) VALUES ('Branch6', 'Programme6', 'TDA011');
INSERT INTO Recommended (branch, programme, course) VALUES ('Branch1', 'Programme7', 'TDA012');
INSERT INTO Recommended (branch, programme, course) VALUES ('Branch2', 'Programme8', 'TDA003');     
INSERT INTO Recommended (branch, programme, course) VALUES ('Branch3', 'Programme9', 'TDA002');
INSERT INTO Recommended (branch, programme, course) VALUES ('Branch4', 'Programme10', 'TDA001');

-- Classificationsz
INSERT INTO Classifications (class) VALUES ('Computer Science');
INSERT INTO Classifications (class) VALUES ('Philosophy');
INSERT INTO Classifications (class) VALUES ('Research');
INSERT INTO Classifications (class) VALUES ('Seminar');
INSERT INTO Classifications (class) VALUES ('Classification5');
INSERT INTO Classifications (class) VALUES ('Math');
INSERT INTO Classifications (class) VALUES ('Classification7');
INSERT INTO Classifications (class) VALUES ('Robotics');
INSERT INTO Classifications (class) VALUES ('AI');
INSERT INTO Classifications (class) VALUES ('Biology');


-- Classifications linked to courses
INSERT INTO HasClass (course,class) VALUES ('TDA001','Computer Science');
INSERT INTO HasClass (course,class) VALUES ('TDA002','Philosophy');
INSERT INTO HasClass (course,class) VALUES ('TDA002','Biology');
INSERT INTO HasClass (course,class) VALUES ('TDA003','Research');
INSERT INTO HasClass (course,class) VALUES ('TDA003','Biology');
INSERT INTO HasClass (course,class) VALUES ('TDA004','Seminar');
INSERT INTO HasClass (course,class) VALUES ('TDA006','Math');
INSERT INTO HasClass (course,class) VALUES ('TDA007','Classification7');
INSERT INTO HasClass (course,class) VALUES ('TDA008','Computer Science');
INSERT INTO HasClass (course,class) VALUES ('TDA009','Philosophy');
INSERT INTO HasClass (course,class) VALUES ('TDA010','Research');
INSERT INTO HasClass (course,class) VALUES ('TDA010','Math');
INSERT INTO HasClass (course,class) VALUES ('TDA001','Seminar');
INSERT INTO HasClass (course,class) VALUES ('TDA001','Classification5');
INSERT INTO HasClass (course,class) VALUES ('TDA013','Math');
INSERT INTO HasClass (course,class) VALUES ('TDA005','Computer Science');
INSERT INTO HasClass (course,class) VALUES ('TDA005','Robotics');
INSERT INTO HasClass (course,class) VALUES ('TDA005','AI');
INSERT INTO HasClass (course,class) VALUES ('TDA015','Math');
INSERT INTO HasClass (course,class) VALUES ('TDA015','Research');
