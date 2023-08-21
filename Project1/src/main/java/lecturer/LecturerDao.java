package lecturer;

import util.DatabaseUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class LecturerDao {
    private PreparedStatement pstmt;
    private ResultSet rs;
    private Connection conn;

    // 강사 아이디를 입력받고 강사 이름을 반환
    public String lecturerName(String lecturer_id)
    {
        String SQL = "select name from lecturer where lecturer_id = ? ";
        try{
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, lecturer_id);
            rs = pstmt.executeQuery();
            if(rs.next())
            {
                return rs.getString(1);
            }
            return null; // 해당강사 없음
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null; // 데이터베이스 오류
    }
}
