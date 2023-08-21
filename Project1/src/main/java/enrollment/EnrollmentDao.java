package enrollment;

//import jdk.internal.vm.compiler.collections.EconomicMap;
import util.DatabaseUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

public class EnrollmentDao {
    private PreparedStatement pstmt;
    private ResultSet rs;
    private Connection conn;

    // 수업 아이디를 받고 해당 수업에 수강신청한 사람들의 숫자를 반환한다.
    public String enrollmentPerson(String class_id)
    {
        String SQL = "select count(ifnull(a.class_id_count,0)) from (select count(*) as class_id_count from enrollment where class_id = ? group by class_id) as a";
        try{
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, class_id);
            rs = pstmt.executeQuery();
            if(rs.next())
            {
                return rs.getString(1);
            }
            return null; // 아이디가 없음
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null; // 데이터베이스 오류
    }

    // 학생 아이디를 받고 해당 학생이 수강신청한 수업 목록을 반환한다.
    public ArrayList<String> enrollmentList(String student_id) {
        String SQL = "select class_id from enrollment where student_id = ?";
        ArrayList<String> result = new ArrayList<String>();
        try{
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, student_id);
            rs = pstmt.executeQuery();
            while(rs.next()) {
                result.add(rs.getString(1));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    // 수강 취소 버튼을 눌렀을때 작동
    public int deleteEnrollment(String current_student_id, String class_id) {
        String SQL = "delete from enrollment where student_id = ? and class_id = ?";
        int result = 0;
        try {
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(2, class_id);
            pstmt.setString(1, current_student_id);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    // 수업이 폐강되었을 때 해당 수업을 수강신청 목록에서 삭제
    public int classDeleted(String class_id) {
        String SQL = "delete from enrollment where class_id = ?";
        int result = 0;
        try {
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, class_id);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    // 수강신청 이후 호출, 각종 제한을 테스트한다.
    public int addEnrollment(String current_student_id, String class_id) {
        String SQL = "insert into enrollment " +
                "select distinct ?, ?, (select ifnull(max(enrollment_id),0) from enrollment order by enrollment_id desc limit 1) + 1 " +
                "from class_time join class_t using (class_id) " +
                "where class_id = ?  " +
                "and not exists (select grade from credit join class_t using(course_id) where student_id = ? and course_id =  " +
                "( select distinct course_id from class_t where class_id = ? and grade in (\"B0\",\"B+\",\"A0\",\"A+\"))) " +
                "and person_max > ( select count(ifnull(a.class_id_count,0)) from (select count(*) as class_id_count from enrollment where class_id = ? group by class_id) as a ) " +
                "and (select credit + (select ifnull(sum(credit),0) from enrollment join class_t using(class_id) where (student_id = ?)) from class_t join class_time using (class_id) " +
                "where class_id = ? and period = \'2\') < 19 " +
                "and not exists ( " +
                "select * " +
                "from (select * from enrollment join class_time using (class_id) where student_id = ? and day_of_week in (select day_of_week from class_time " +
                "where class_id = ? and period = \'2\') ) as T " +
                "where ((select begin_time from class_time where class_id = ? and period = \'2\') >= T.begin_time " +
                "and (select begin_time from class_time where class_id = ? and period = \'2\') < T.end_time) " +
                "or ((select end_time from class_time where class_id = ? and period = \'2\') " +
                "<= T.end_time and (select end_time from class_time where class_id = ? and period = \'2\') > T.begin_time));";
        int result = 0;
        try {
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, class_id);
            pstmt.setString(2, current_student_id);
            pstmt.setString(3, class_id);
            pstmt.setString(4, current_student_id);
            pstmt.setString(5, class_id);
            pstmt.setString(6, class_id);
            pstmt.setString(7, current_student_id);
            pstmt.setString(8, class_id);
            pstmt.setString(9, current_student_id);
            pstmt.setString(10, class_id);
            pstmt.setString(11, class_id);
            pstmt.setString(12, class_id);
            pstmt.setString(13, class_id);
            pstmt.setString(14, class_id);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }
}
