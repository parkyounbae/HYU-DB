package class_t;

import class_time.Class_timeDao;
import util.DatabaseUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

public class Class_tDao {
    private PreparedStatement pstmt;
    private ResultSet rs;
    private Connection conn;
    private ArrayList<ClassSearchResult> class_ts;

    // 검색 결과 값을 편리하게 반환하기 위해 이너클래스 제작
    public static class ClassSearchResult {
        private String class_no;
        private String course_id;
        private String class_t_name;
        private String class_t_major;
        private String lecturer_name;
        private String begin_time;
        private String end_time;
        private String enrollment_count;
        private String person_max;
        private String building;
        private String room;
        private String class_id;
        private String day_of_week;
        public ClassSearchResult(){};
        public ClassSearchResult(String class_no, String course_id, String class_t_name, String class_t_major, String lecturer_name, String begin_time, String end_time, String enrollment_count, String person_max,
                                 String building, String room, String class_id, String day_of_week) {
            this.class_no = class_no;
            this.course_id = course_id;
            this.class_t_name = class_t_name;
            this.class_t_major = class_t_major;
            this.lecturer_name = lecturer_name;
            this.begin_time = begin_time;
            this.end_time = end_time;
            this.enrollment_count = enrollment_count;
            this.person_max = person_max;
            this.building = building;
            this.room = room;
            this.class_id = class_id;
            this.day_of_week = day_of_week;
        }

        public String getDay_of_week() {
            return day_of_week;
        }

        public void setDay_of_week(String day_of_week) {
            this.day_of_week = day_of_week;
        }

        public String getClass_no() {
            return class_no;
        }

        public void setClass_no(String class_no) {
            this.class_no = class_no;
        }

        public String getCourse_id() {
            return course_id;
        }

        public void setCourse_id(String course_id) {
            this.course_id = course_id;
        }

        public String getClass_t_name() {
            return class_t_name;
        }

        public void setClass_t_name(String class_t_name) {
            this.class_t_name = class_t_name;
        }

        public String getClass_t_major() {
            return class_t_major;
        }

        public void setClass_t_major(String class_t_major) {
            this.class_t_major = class_t_major;
        }

        public String getLecturer_name() {
            return lecturer_name;
        }

        public void setLecturer_name(String lecturer_name) {
            this.lecturer_name = lecturer_name;
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

        public String getEnrollment_count() {
            return enrollment_count;
        }

        public void setEnrollment_count(String enrollment_count) {
            this.enrollment_count = enrollment_count;
        }

        public String getPerson_max() {
            return person_max;
        }

        public void setPerson_max(String person_max) {
            this.person_max = person_max;
        }

        public String getBuilding() {
            return building;
        }

        public void setBuilding(String building) {
            this.building = building;
        }

        public String getRoom() {
            return room;
        }

        public void setRoom(String room) {
            this.room = room;
        }

        public String getClass_id() {
            return class_id;
        }

        public void setClass_id(String class_id) {
            this.class_id = class_id;
        }
    }

    // 수업을 삭제할때 호출
    public int deleteClass(String class_id) {
        String SQL = "delete from class_t where class_id = ?";
        int result = 0;
        try{
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, class_id);
            result = pstmt.executeUpdate(); // 성공한다면 삭제된 개수 반환
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    // 새로운 수업을 만들기 위한 함수
    public int makeNewClass(String class_id, String class_no, String course_id, String name, String major_id, String class_year, String credit, String lecturer_id, String person_max, String opened, String room_id) {
        String SQL = "insert into class_t value(?,?,?,?,?,?,?,?,?,?,?)";
        int result = 0;
        try{
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, class_id);
            pstmt.setString(2, class_no);
            pstmt.setString(3, course_id);
            pstmt.setString(4, name);
            pstmt.setString(5, major_id);
            pstmt.setString(6, class_year);
            pstmt.setString(7, credit);
            pstmt.setString(8, lecturer_id);
            pstmt.setString(9, person_max);
            pstmt.setString(10, opened);
            pstmt.setString(11, room_id);
            result = pstmt.executeUpdate(); // 성공한다면 추가된 수업 개수 반환
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    // 수강인원 증원할때 사용
    public int incrClass(String num, String class_id) {
        String SQL = "update class_t set person_max = ? where class_id = ?";
        int result = 0;

        try{
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, num);
            pstmt.setString(2, class_id);
            result = pstmt.executeUpdate(); // 성공시 증원한 수업개수 반환
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    // 수업 검색할때 사용
    public ArrayList<ClassSearchResult> searchClass(String searchType, String searchKeyword) {
        // 유형에 따라 SQL 구문의 종류가 다르기 때문에 일단 구문을 비칸으로 저장해둔다.
        String SQL = "";

        try {
            conn = DatabaseUtil.getConnection();
            if(searchType.equals("class_no")) {
                // class_no를 통해 검색하는 경우
                SQL = "SELECT class_no, course_id, class_t.name as class_t_name, class_t.major_id as class_t_major, lecturer.name as lecturer_name, class_time.begin_time, class_time.end_time, " +
                        "(select count(ifnull(a.enrollment_count,0)) from (select count(*) as enrollment_count from enrollment where class_id in (select class_id from class_t where class_no = ? and opened = \"2022\") group by class_id) as a), " +
                        "person_max, building.name as building_name, building.rooms, class_id,class_time.day_of_week" +
                        " FROM class_t join lecturer using (lecturer_id) join class_time using (class_id) join room using (room_id) join building using (building_id)" +
                        " where class_no = ? and opened = \"2022\" and period = \"2\"";
            } else if(searchType.equals("course_id")) {
                // course_id 를 통해 검색하는 경우
                SQL = "SELECT class_no, course_id, class_t.name as class_t_name, class_t.major_id as class_t_major, lecturer.name as lecturer_name, class_time.begin_time, class_time.end_time, " +
                        "(select count(*) as enrollment_count from enrollment where class_id in (select class_id from class_t where course_id = ? and opened = \"2022\") group by class_id) as enrollment_count, " +
                        "person_max, building.name as building_name, building.rooms, class_id,class_time.day_of_week" +
                        " FROM class_t join lecturer using (lecturer_id) join class_time using (class_id) join room using (room_id) join building using (building_id)" +
                        " where course_id = ? and opened = \"2022\" and period = \"2\"";
            } else if (searchType.equals("name")) {
                // name 을 통해 검색하는 경우
                SQL = "SELECT class_no, course_id, class_t.name as class_t_name, class_t.major_id as class_t_major, lecturer.name as lecturer_name, class_time.begin_time, class_time.end_time, " +
                        "(select count(*) as enrollment_count from enrollment group by class_id limit 1) as enrollment_count, person_max, building.name as building_name, building.rooms, class_id,class_time.day_of_week" +
                        " FROM class_t join lecturer using (lecturer_id) join class_time using (class_id) join room using (room_id) join building using (building_id)" +
                        " where class_t.name like ? and opened = \"2022\" and period = \"2\"";
            } else if (searchType.equals("class_id")) {
                // class_id 를 통해 검색하는 경우
                SQL = "SELECT class_no, course_id, class_t.name as class_t_name, class_t.major_id as class_t_major, lecturer.name as lecturer_name, class_time.begin_time, class_time.end_time, " +
                        "(select count(*) as enrollment_count from enrollment group by class_id having class_id = ?) as enrollment_count, person_max, building.name as building_name, building.rooms, class_id,class_time.day_of_week" +
                        " FROM class_t join lecturer using (lecturer_id) join class_time using (class_id) join room using (room_id) join building using (building_id)" +
                        " where class_id = ? and opened = \"2022\" and period = \"2\"";
            }
            pstmt = conn.prepareStatement(SQL);

            if (searchType.equals("name")){
                // 이름으로 검색하는 경우 일부분만 맞아도 검색 결과를 반환해야 하기 때문에 인자에 % 를 추가한다.
                pstmt.setString(1, "%" + searchKeyword + "%");
            } else {
                // 나머지의 경우 각각 추가
                pstmt.setString(1, searchKeyword);
                pstmt.setString(2, searchKeyword);
            }
            rs = pstmt.executeQuery();
            class_ts = new ArrayList<ClassSearchResult>();
            // 검색 결과가 여려개가 나올수도 있으니 안나올때 까지 반복문으로
            while(rs.next())
            {
                // 입력 된 정보로 새로운 객체를 만들고 배열에 추가
                ClassSearchResult class_t = new ClassSearchResult(rs.getString(1),rs.getString(2),rs.getString(3),rs.getString(4),rs.getString(5),rs.getString(6),
                        rs.getString(7),rs.getString(8),rs.getString(9),rs.getString(10),rs.getString(11),rs.getString(12),rs.getString(13));
                class_ts.add(class_t);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return class_ts; // 완성된 배열 반환, 검색 결과 없으면 null 반환
    }

}
