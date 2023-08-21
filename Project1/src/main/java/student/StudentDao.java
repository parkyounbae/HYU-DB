package student;

import util.DatabaseUtil;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class StudentDao {
    private PreparedStatement pstmt;
    private ResultSet rs;
    private Connection conn;

    // 학번을 입력받고 해당 학번을 가진 학생의 정보를 반환한다.
    public Student searchStudent(String student_id) {
        String SQL = "select * from student where student_id = ?";

        try{
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, student_id);
            rs = pstmt.executeQuery();
            if(rs.next())
            {
                Student student = new Student();
                student.setStudent_id(Integer.parseInt(rs.getString(1)));
                student.setUserPassword(rs.getString(2));
                student.setName(rs.getString(3));
                student.setSex(rs.getString(4));
                student.setMajor_id(Integer.parseInt(rs.getString(5)));
                student.setLecturer_id(Integer.parseInt(rs.getString(6)));
                student.setYear(Integer.parseInt(rs.getString(7)));
                student.setCurrent_status(rs.getString(8));
                return student;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null; // 데이터베이스 오류
    }

    // 해당 학생의 상태를 변경해줌
    public int changeStatus(String student_id, String status) {
        String SQL = "update student set current_status = ? where student_id = ?";
        int result = 0;
        try {
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, status);
            pstmt.setString(2,student_id);
            result = pstmt.executeUpdate(); // 변경 성공시 1 반환
        } catch (Exception e) {
            e.printStackTrace();
        }

        return result; // 변경하지 못했으면 0 반환
    }

    // 로그인 시도
    public int login(String id_from_web, String password_from_web)
    {
        String SQL = "SELECT password FROM Student WHERE student_id = ?";
        try{
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, id_from_web);
            rs = pstmt.executeQuery();
            if(rs.next())
            {
                if(rs.getString(1).equals(password_from_web))
                {
                    return 1; //로그인 성공
                }
                else
                {
                    return 0; //비밀번호 불일치
                }
            }
            return -1; // 아이디가 없음
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -2; // 데이터베이스 오류
    }


}
