package class_time;

import util.DatabaseUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class Class_timeDao {
    private PreparedStatement pstmt;
    private ResultSet rs;
    private Connection conn;

    // 수업 시간 검색 결과를 편리하게 반환하기 위해 이너클래스 제작
    public class TimeInfo {
        private String begin_time;
        private String end_time;
        private String name;
        private String dayOfWeek;

        public TimeInfo(String begin_time, String end_time, String name, String dayOfWeek) {
            this.begin_time = begin_time;
            this.end_time = end_time;
            this.name = name;
            this.dayOfWeek = dayOfWeek;
        }

        public String getDayOfWeek() {
            return dayOfWeek;
        }

        public void setDayOfWeek(String dayOfWeek) {
            this.dayOfWeek = dayOfWeek;
        }

        public String getBegin_time() {
            return begin_time;
        }

        public void setBegin_time(String begin_time) {
            this.begin_time = begin_time;
        }

        public String getEnd_time() {
            return end_time;
        }

        public void setEnd_time(String end_time) {
            this.end_time = end_time;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        // 문자열로 제공된 시작시간을 정수값으로 반환 09:00 -> 900
        public int stringTimeToInt() {
            String[] timeTable = this.begin_time.split(":");
            if(timeTable.length == 2) {
                int result = Integer.parseInt(timeTable[0])*100 + Integer.parseInt(timeTable[1]);
                return result;
            }
            return -1;
        }
        // 문자열로 제공된 종료시간을 정수값으로 반환 09:00 -> 900
        public int stringEndTimeToInt() {
            String[] timeTable = this.end_time.split(":");
            if(timeTable.length == 2) {
                int result = Integer.parseInt(timeTable[0])*100 + Integer.parseInt(timeTable[1]);
                return result;
            }
            return -1;
        }

        // 30분을 기준으로 수업이 얼마나 진행되는지 반환 30분 = 1, 1시간 = 2
        public int spanCount() {
            int startTime = stringTimeToInt();
            int endTime = stringEndTimeToInt();

            // 오전 오후를 구분하기 위한 조건문
            if(startTime < 600) {
                int temp = endTime -startTime;
                return 2*(temp/100) +(temp%100)/30;
            } else if (startTime>800 && endTime>800) {
                int temp = endTime -startTime;
                return 2*(temp/100) +(temp%100)/30;
            } else if(startTime>800 && endTime<600){
                startTime -= 1200;
                int temp = endTime -startTime;
                return 2*(temp/100) +(temp%100)/30;
            }
            else return 0;
        }
    }

    // 수업이 삭제되었을때 해당하는 수업의 time 객체를 삭제
    public int classDeleted(String class_id) {
        String SQL = "delete from class_time where class_id = ?";
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

    // 새로운 수업이 생성 되었을때 해당 수업의 class_time 객체를 생성하고 넣어줌
    public int addClassTime(String class_id, String period, String begin_time, String end_time, String day_of_week) {
        String SQL = "insert into class_time " +
                "select (select ifnull(max(time_id),0) from class_time order by time_id desc limit 1) + 1,?,?,?,?,?";
        int result = 0;
        try{
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, class_id);
            pstmt.setString(2, period);
            pstmt.setString(3, begin_time);
            pstmt.setString(4, end_time);
            pstmt.setString(5, day_of_week);
            result = pstmt.executeUpdate();
            return result;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    // 해당하는 수업의 시작 시간,종료 시간, 요일, 이름 을 반환한다.
    public TimeInfo classTime(String class_id)
    {
        String SQL = "select begin_time, end_time, name, day_of_week from class_time join class_t using(class_id) where class_id = ? ";
        try{
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, class_id);
            rs = pstmt.executeQuery();
            if(rs.next())
            {
                TimeInfo timeInfo = new TimeInfo(rs.getString(1),rs.getString(2),rs.getString(3),rs.getString(4));
                return timeInfo;
            }
            return null; // 아이디가 없음
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null; // 데이터베이스 오류
    }
}
