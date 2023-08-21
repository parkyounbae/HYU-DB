package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DatabaseUtil {
    public static Connection getConnection() {
        try{
            String dbURL = "jdbc:mysql://localhost:3307/DB2019038513?serverTimezone=Asia/Seoul";
            String dbID = "root";
            String dbPassword = "ipark201904";
            Class.forName("com.mysql.jdbc.Driver");
            return DriverManager.getConnection(dbURL, dbID, dbPassword);
        } catch (Exception e){
            e.printStackTrace();
        }
        return null;
    }
}
