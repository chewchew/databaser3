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
    //static final String USERNAME = "tda357_003";
    static final String USERNAME = "postgres";
    //static final String PASSWORD = "DKGBgwWY";
    static final String PASSWORD = "";

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
            //String url = "jdbc:postgresql://ate.ita.chalmers.se/";
            String url = "jdbc:postgresql://localhost/uni";
            Properties props = new Properties();
            props.setProperty("user",USERNAME);
            props.setProperty("password",PASSWORD);
            Connection conn = DriverManager.getConnection(url, props);

            String student = args[0]; // This is the identifier for the student.

            Console console = System.console();
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

    static void printColumns(ResultSet rs, String[] columns, 
        boolean indent, String separator, boolean printColumn) throws SQLException {
        String tab;
        if (indent) {
            tab = "\t";
        } else {
            tab = "";
        }
        for (int i = 0; i < columns.length; i++) {
            String column = columns[i];
            System.out.println(tab + (printColumn ? column + ": " : "") + rs.getString(column));
        }
        System.out.println(separator);
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

    static void getInformationHelper(Connection conn, String student, 
        String query, String[] columns, boolean indent, String separator, boolean printColumn) throws SQLException {
        
        PreparedStatement stmt = 
                conn.prepareStatement(query);
        stmt.setString(1, student);
        ResultSet rs = stmt.executeQuery();
        while(rs.next()){
            printColumns(rs, columns, indent, separator, printColumn);
        }
        stmt.close();
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
                "SELECT studentnin,course,grade "+
                "FROM FinishedCourses WHERE studentnin = ?",
                new String[]{"Course","Grade"}, true, "\n",true);
            
            System.out.println("Registrations:");
            getInformationHelper(conn, student, 
                "SELECT * FROM Registrations WHERE student = ?",
                new String[]{"Course","Status"}, true, "\n",true);

            System.out.println("Unread Mandatory Courses:");
            getInformationHelper(conn, student, 
                "SELECT * FROM UnreadMandatory WHERE nin = ?",
                new String[]{"Course"}, true, "\n",true);

            System.out.println("Graduation Status:");
            getInformationHelper(conn, student,
                "SELECT graduation FROM PathToGraduation WHERE nin = ?",
                new String[]{"Graduation"}, false, "",false);
        } catch (SQLException e) {
            System.out.println(""+e);
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
                conn.prepareStatement("INSERT INTO Registrations (student,course,status) VALUES (?,?,?)");
            stmt.setString(1,student);
            stmt.setString(2,course);
            stmt.setString(3,"registered");

            stmt.executeUpdate();
            
            System.out.println("Success");
        } catch (SQLException e) {
            System.out.println("Failure");
        } 
    }

    /* Unregister: Given a student id number and a course code, this function
     * should unregister the student from that course.
     */
    static void unregisterStudent(Connection conn, String student, String course)
            throws SQLException
    {
        // TODO: Your implementation here
    }
}