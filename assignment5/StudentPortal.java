/* This is the driving engine of the program. It parses the command-line
 * arguments and calls the appropriate methods in the other classes.
 *
 * You should edit this file in two ways:
 * 1) Insert your database username and password in the proper places.
 * 2) Implement the three functions getInformation, registerStudent
 *    and unregisterStudent.
 */
import java.sql.*; // JDBC stuff.
import java.util.Properties;
import java.util.Scanner;
import java.io.*;  // Reading user input.

public class StudentPortal
{
    /* TODO Here you should put your database name, username and password */
    static final String USERNAME = "tda357_003";
    // static final String USERNAME = "andreas";
    static final String PASSWORD = "DKGBgwWY";
    // static final String PASSWORD = "bigbang";

    /* Print command usage.
     * /!\ you don't need to change this function! */
    public static void usage () {
        System.out.println("Usage:");
        System.out.println("    i[nformation]");
        System.out.println("    r[egister] <course>");
        System.out.println("    u[nregister] <course>");
        System.out.println("    q[uit]");
    }

    /* main: parses the input commands.
     * /!\ You don't need to change this function! */
    public static void main(String[] args) throws Exception
    {
        try {
            Class.forName("org.postgresql.Driver");
            String url = "jdbc:postgresql://ate.ita.chalmers.se/";
            //String url = "jdbc:postgresql://localhost/uni";
            Properties props = new Properties();
            props.setProperty("user",USERNAME);
            props.setProperty("password",PASSWORD);
            Connection conn = DriverManager.getConnection(url, props);

            String student = args[0]; // This is the identifier for the student.

            Console console = System.console();

            
            System.out.println(console);
            
            usage();
            System.out.println("Welcome!");
            while(true) {
                String mode = console.readLine("? > ");
                String[] cmd = mode.split(" +");
                cmd[0] = cmd[0].toLowerCase();
                if ("information".startsWith(cmd[0]) && cmd.length == 1) {
                    /* Information mode */
                    getInformation(conn, student);
                } else if ("register".startsWith(cmd[0]) && cmd.length == 2) {
                    /* Register student mode */
                    registerStudent(conn, student, cmd[1]);
                } else if ("unregister".startsWith(cmd[0]) && cmd.length == 2) {
                    /* Unregister student mode */
                    unregisterStudent(conn, student, cmd[1]);
                } else if ("quit".startsWith(cmd[0])) {
                    break;
                } else usage();
            }
            System.out.println("Goodbye!");
            conn.close();
        } catch (SQLException e) {
            System.err.println(e);
            System.exit(2);
        }
    }

    /*
        Print the column the given resultset with the given columnames.
    */
    static void printColumns(ResultSet rs, String[] columns, String[] labeling, 
        boolean indent, String separator, boolean printColumn) throws SQLException {
        String tab, column, label;
        tab = indent? "\t":"";

        for (int i = 0; i < columns.length; i++) {
            column = columns[i];
            label = labeling[i];
            System.out.println(tab + (printColumn ? label + ": " : "") + rs.getString(column));
        }
        System.out.println(separator);
    }

    static void printColumns(ResultSet rs, String[] columns, 
        boolean indent, String separator, boolean printColumn) throws SQLException {
        printColumns(rs, columns, columns, indent, separator, printColumn);
    }

    // UNUSED CURRENTLY
    static boolean columnInTable(ResultSet rs, String column) throws SQLException{
        ResultSetMetaData rsmd = rs.getMetaData();
        System.out.println(""+rsmd.getColumnCount());
        for (int i = 1; i <= rsmd.getColumnCount(); i++) {
            if (column.equals(rsmd.getColumnName(i))) {
                return true;
            }
        }
        return false;
    }

    /*
        Execute and print a query
    */
    static void getInformationHelper(Connection conn, String student, 
        String query, String[] columns, String[] labeling, boolean indent, String separator, boolean printColumn) throws SQLException {
        
        PreparedStatement stmt = 
                conn.prepareStatement(query);
        stmt.setString(1, student);
        ResultSet rs = stmt.executeQuery();
        while(rs.next()){
            printColumns(rs, columns, labeling, indent, separator, printColumn);
        }
        stmt.close();
    }

    static void getInformationHelper(Connection conn, String student, 
        String query, String[] columns, boolean indent, String separator, boolean printColumn) throws SQLException {
        getInformationHelper(conn, student, query, columns, columns, indent, separator, printColumn);
    }

    /* Given a student identification number, ths function should print
     * - the name of the student, the students national identification number
     *   and their issued login name (something similar to a CID)
     * - the programme and branch (if any) that the student is following.
     * - the courses that the student has read, along with the grade.
     * - the courses that the student is registered to. (queue position if the student is waiting for the course)
     * - the number of mandatory courses that the student has yet to read.
     * - whether or not the student fulfills the requirements for graduation
     */
    static void getInformation(Connection conn, String student) throws SQLException
    {
        try {
            getInformationHelper(conn, student, 
                "SELECT * FROM Students WHERE Students.NIN = ?", 
                new String[]{"NIN","Name","LoginID","Programme"}, false, "",true);

            getInformationHelper(conn, student, 
                "SELECT branch FROM StudentsFollowing WHERE NIN = ?", 
                new String[]{"Branch"}, false, "",true);

            System.out.println("Read Courses:");
            getInformationHelper(conn, student, 
                "SELECT * "+
                "FROM FinishedCourses f JOIN Courses c ON f.course = c.code "+
                "WHERE studentnin = ?",
                new String[]{"Course", "Name", "Grade"}, true, "\n",true);
            
            System.out.println("Registrations:");
            getInformationHelper(conn, student, 
                "SELECT * "+
                "FROM Registrations r JOIN Courses c ON r.course = c.code " +
                "WHERE student = ? AND status = 'Registered'",
                new String[]{"Course","Name","Status"}, true, "\n",true);

            getInformationHelper(conn, student, 
                "SELECT * "+
                "FROM (Registrations r JOIN Courses c ON r.course = c.code) "+
                "NATURAL JOIN CourseQueuePositions q "+
                "WHERE student = ?",
                new String[]{"Course","Name","Status","Position"}, true, "\n",true);

            System.out.println("Unread Mandatory Courses:");
            getInformationHelper(conn, student, 
                "SELECT * "+
                "FROM UnreadMandatory u JOIN Courses c ON u.course = c.code "+
                "WHERE nin = ?",
                new String[]{"Course", "Name"}, true, "\n",true);

            System.out.println("Credits and Requirements:");
            getInformationHelper(conn, student, 
                "SELECT * "+
                "FROM PathToGraduation "+
                "WHERE nin = ?",
                new String[]{"CollectedCredits","MathCredits","ResearchCredits","ReadSeminarCourses"},
                new String[]{"Total Credits",
                "Math Credits (Of Needed 20)", 
                "Research Credits (Of Needed 10)",
                "Number of Read Seminar Courses"}, true, "\n",true);            

            System.out.println("Graduation Status:");
            getInformationHelper(conn, student,
                "SELECT graduation FROM PathToGraduation WHERE nin = ?",
                new String[]{"Graduation"}, false, "",false);
        } catch (SQLException e) {
            System.out.println(e);
        }
    }

    /* Register: Given a student id number and a course code, this function
     * should try to register the student for that course.
     */
    static void registerStudent(Connection conn, String student, String course)
            throws SQLException
    {
        try {
            PreparedStatement stmt = 
                conn.prepareStatement("INSERT INTO Registrations (student,course) VALUES (?,?)");
            stmt.setString(1,student);
            stmt.setString(2,course);

            stmt.executeUpdate();
            stmt.close();           
            System.out.println("Success");
        } catch (SQLException e) {
            System.out.println("Failure:");
            System.out.println(e.getMessage());
        } 
    }

    /* Unregister: Given a student id number and a course code, this function
     * should unregister the student from that course.

        TODO: The delete statement will not execute if the where clause evaluates to false.
                This means that deleting an unregisterd and unwaiting student will cause
                a "success" printout. I don't quite know if this should be regarded
                as intentional behaviour.

     */
    static void unregisterStudent(Connection conn, String student, String course)
            throws SQLException
    {
        try {
            PreparedStatement check =
                conn.prepareStatement("SELECT * FROM Registrations WHERE student = ? AND course = ?");
            check.setString(1,student);
            check.setString(2,course);
            boolean exists = false;
            ResultSet rs = check.executeQuery();
            while(rs.next()) {
                exists = true;
                break;
            }
            if (!exists) {
                throw new SQLException("Student is not waiting for or registered on that course!");
            }
            check.close();

            PreparedStatement stmt = 
                conn.prepareStatement("DELETE FROM Registrations WHERE student = ? AND course = ?");
            stmt.setString(1,student);
            stmt.setString(2,course);

            stmt.executeUpdate();
            stmt.close();

            System.out.println("Success");
        } catch (SQLException e) {
            System.out.println("Failure:");
            System.out.println(e.getMessage());
        }
    }
}