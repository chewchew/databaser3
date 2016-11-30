-- Test Data --

-- Departments
INSERT INTO Departments (name,abbreviation) VALUES ('Department1','D1');
INSERT INTO Departments (name,abbreviation) VALUES ('Department2','D2');
INSERT INTO Departments (name,abbreviation) VALUES ('Department3','D3');
INSERT INTO Departments (name,abbreviation) VALUES ('Department4','D4');
INSERT INTO Departments (name,abbreviation) VALUES ('Department5','D5');
INSERT INTO Departments (name,abbreviation) VALUES ('Department6','D6');

-- Programmes
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
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150001','Name1','loginId1','Branch1','Programme1');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150002','Name2','loginId2','Branch2','Programme2');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150003','Name3','loginId3','Branch3','Programme3');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150004','Name4','loginId4','Branch4','Programme4');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150005','Name5','loginId5','Branch5','Programme5');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150006','Name6','loginId6','Branch6','Programme6');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150007','Name7','loginId7','Branch1','Programme7');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150008','Name8','loginId8','Branch2','Programme8');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150009','Name9','loginId9','Branch3','Programme9');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150010','Name10','loginId10','Branch4','Programme10');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150011','Name11','loginId11','Branch5','Programme1');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150012','Name12','loginId12','Branch6','Programme2');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150013','Name13','loginId13','Branch5','Programme1');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150014','Name14','loginId14','Branch2','Programme2');
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150015','Name15','loginId15','Branch1','Programme1');
-- should fail
INSERT INTO Students (NIN,name,loginID,branch,programme) VALUES ('9008150015','Name16','loginId16','Branch2','Programme1');

-- Courses
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA001','Course1',7.5,'Department1');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA002','Course2',7.5,'Department2');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA003','Course3',7.5,'Department3');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA004','Course4',7.5,'Department4');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA005','Course5',7.5,'Department5');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA006','Course6',7.5,'Department6');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA007','Course7',7.5,'Department1');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA008','Course8',7.5,'Department2');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA009','Course9',7.5,'Department3');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA010','Course10',7.5,'Department4');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA011','Course11',7.5,'Department5');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA012','Course12',7.5,'Department6');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA013','Course13',7.5,'Department1');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA014','Course14',7.5,'Department2');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA015','Course15',7.5,'Department3');
INSERT INTO Courses (code,name,credits,department) VALUES ('TDA016','Course16',7.5,'Department4');

-- Courses with student limit
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA001',101);
--INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA002',102);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA003',103);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA004',104);
--INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA005',105);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA006',106);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA007',107);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA008',108);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA009',109);
--INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA010',101);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA011',102);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA012',103);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA013',104);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA014',105);
--INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA015',110);
INSERT INTO LimitedCourses (code,studentLimit) VALUES ('TDA016',120);

INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA001','TDA003');
INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA001','TDA004');
INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA003','TDA006');
INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA004','TDA006');
INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA014','TDA003');
-- should fail
INSERT INTO Prerequisite (prerequisite,toCourse) VALUES ('TDA006','TDA001');

-- Student information

-- Program 1 mandatory
-- TDA011, limited course
-- TDA016, unlimited
--
-- Program 1, branch 1 mandatory
-- TDA001, limited course
-- TDA014, limited
-- TDA010, unlimited

-- student 1, ready for graduation
INSERT INTO Finished (student,course,grade) VALUES ('9008150001','TDA011','4');
INSERT INTO Finished (student,course,grade) VALUES ('9008150001','TDA016','3');
INSERT INTO Finished (student,course,grade) VALUES ('9008150001','TDA001','5');
INSERT INTO Finished (student,course,grade) VALUES ('9008150001','TDA014','3');
INSERT INTO Finished (student,course,grade) VALUES ('9008150001','TDA010','5');
INSERT INTO Finished (student,course,grade) VALUES ('9008150001','TDA007','4');

-- student 15, registred on mand course TDA010, waiting on TDA008
INSERT INTO Finished (student,course,grade) VALUES ('9008150015','TDA011','U');
INSERT INTO Finished (student,course,grade) VALUES ('9008150015','TDA016','3');
INSERT INTO Finished (student,course,grade) VALUES ('9008150015','TDA001','5');
INSERT INTO Finished (student,course,grade) VALUES ('9008150015','TDA014','3');
--INSERT INTO Finished (student,course,grade) VALUES ('9008150015','TDA010','5');
INSERT INTO Finished (student,course,grade) VALUES ('9008150015','TDA007','4');

INSERT INTO Registered (student, course) VALUES ('9008150015', 'TDA010');
INSERT INTO WaitingOn (student, course, date) VALUES ('9008150015', 'TDA008','3/8/15 00:00:00');

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
INSERT INTO BranchMandatory (branch, programme, course) VALUES ('Branch5', 'Programme5', 'TDA006');
INSERT INTO BranchMandatory (branch, programme, course) VALUES ('Branch6', 'Programme6', 'TDA002');
INSERT INTO BranchMandatory (branch, programme, course) VALUES ('Branch1', 'Programme7', 'TDA001');

INSERT INTO Classifications (class) VALUES ('Classification1');
INSERT INTO Classifications (class) VALUES ('Classification2');
INSERT INTO Classifications (class) VALUES ('Classification3');
INSERT INTO Classifications (class) VALUES ('Classification4');
INSERT INTO Classifications (class) VALUES ('Classification5');
INSERT INTO Classifications (class) VALUES ('Classification6');
INSERT INTO Classifications (class) VALUES ('Classification7');

INSERT INTO HasClass (course,class) VALUES ('TDA001','Classification1');
INSERT INTO HasClass (course,class) VALUES ('TDA002','Classification2');
INSERT INTO HasClass (course,class) VALUES ('TDA003','Classification3');
INSERT INTO HasClass (course,class) VALUES ('TDA004','Classification4');
INSERT INTO HasClass (course,class) VALUES ('TDA005','Classification5');
INSERT INTO HasClass (course,class) VALUES ('TDA006','Classification6');
INSERT INTO HasClass (course,class) VALUES ('TDA007','Classification7');
INSERT INTO HasClass (course,class) VALUES ('TDA008','Classification1');
INSERT INTO HasClass (course,class) VALUES ('TDA009','Classification2');
INSERT INTO HasClass (course,class) VALUES ('TDA010','Classification3');
INSERT INTO HasClass (course,class) VALUES ('TDA001','Classification4');
INSERT INTO HasClass (course,class) VALUES ('TDA001','Classification5');
INSERT INTO HasClass (course,class) VALUES ('TDA013','Classification6');
INSERT INTO HasClass (course,class) VALUES ('TDA005','Classification7');


SELECT * FROM Departments;
SELECT * FROM Programmes;
SELECT * FROM HostedBy;
SELECT * FROM Branches;
SELECT * FROM Students;
SELECT * FROM Courses;
