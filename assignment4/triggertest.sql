
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
INSERT INTO Registrations (student, course) VALUES ('9008150006', 'TDA009');
INSERT INTO Registrations (student, course) VALUES ('9008150007', 'TDA009');
INSERT INTO Registrations (student, course) VALUES ('9008150008', 'TDA009');


-- 3 regesitered students and 4 waiting students on course TDA008
INSERT INTO Registrations (student, course) VALUES ('9008150003', 'TDA008');
INSERT INTO Registrations (student, course) VALUES ('9008150004', 'TDA008');
INSERT INTO Registrations (student, course) VALUES ('9008150005', 'TDA008');
INSERT INTO Registrations (student, course) VALUES ('9008150006', 'TDA008');
INSERT INTO Registrations (student, course) VALUES ('9008150007', 'TDA008');
INSERT INTO Registrations (student, course) VALUES ('9008150008', 'TDA008');
INSERT INTO Registrations (student, course) VALUES ('9008150015', 'TDA008');

INSERT INTO Registrations (student, course) VALUES ('9008150009', 'TDA014');
INSERT INTO Registrations (student, course) VALUES ('9008150015', 'TDA010');
