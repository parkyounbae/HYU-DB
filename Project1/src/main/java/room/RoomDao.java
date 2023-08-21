package room;

import util.DatabaseUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class RoomDao {
    private PreparedStatement pstmt;
    private ResultSet rs;
    private Connection conn;

    // 강의실 아이디 받고 해당 강의실의 수용인원 반환
    public String getMaxPerson(String room_id) {
        String SQL = "select occupancy from room where room_id = ?";
        try{
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, room_id);
            rs = pstmt.executeQuery();
            if(rs.next())
            {
                return rs.getString(1);
            }
            return null; // 해당 강의실 없음
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null; // 데이터베이스 오류
    }
}
