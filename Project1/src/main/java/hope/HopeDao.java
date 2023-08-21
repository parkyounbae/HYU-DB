package hope;

import util.DatabaseUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

public class HopeDao {
    private PreparedStatement pstmt;
    private ResultSet rs;
    private Connection conn;

    // 해당 학생에 대한 희망 수업 리스트를 반환한다.
    public ArrayList<String> hopeList(String student_id)
    {
        String SQL = "select class_id from hope where student_id = ?";
        ArrayList<String> hopes = new ArrayList<String>();;
        try{
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, student_id);
            rs = pstmt.executeQuery();
            while(rs.next())
            {
                hopes.add(rs.getString(1));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return hopes; // 없으면 널값 반환 있으면 정상적인 배열 반환
    }

    // 희망수업에 추가하였을때 호출
    public int addHope(String student_id, String class_id) {
        int result = 0;
        String SQL = "insert into hope select distinct ?, ?, (select ifnull(max(hope_id),0) from hope order by hope_id desc limit 1) + 1 " +
            "from class_t " +
            "where not exists (select class_id from hope where class_id = ? and student_id = ?) and not exists (select class_id from enrollment where class_id = ? and student_id = ?)";

        try{
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, class_id);
            pstmt.setString(2, student_id);
            pstmt.setString(3, class_id);
            pstmt.setString(4, student_id);
            pstmt.setString(5, class_id);
            pstmt.setString(6, student_id);
            result = pstmt.executeUpdate(); // 추가된 강의 수 반환
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result; // 없으면 0 반환
    }

    // 해당 수업이 삭제되었을때 희망 강의 목록에서 해당 강의 모두 삭제
    public int classDeleted(String class_id) {
        String SQL = "delete from hope where class_id = ?";
        int result = 0;
        try {
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, class_id);
            result = pstmt.executeUpdate(); // 삭제된 강의 수 반환
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result; // 없으면 0 반환
    }

    // 희망 목록에서 삭제하였을 때
    public int deleteHope(String student_id, String class_id) {
        String SQL = "delete from hope where student_id = ? and class_id = ?";
        int result = 0;
        try{
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, student_id);
            pstmt.setString(2, class_id);
            result = pstmt.executeUpdate(); //삭제된 강의 수 반환
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result; // 없으면 0 반환
    }
}
