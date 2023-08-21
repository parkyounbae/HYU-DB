package admin;

import util.DatabaseUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class AdminDao {
    private PreparedStatement pstmt;
    private ResultSet rs;

    // 어드민의 로그인 함수
    public int login(String id_from_web, String password_from_web)
    {
        String SQL = "SELECT password FROM admin WHERE admin_id = ?";
        try{
            Connection conn = DatabaseUtil.getConnection();
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
