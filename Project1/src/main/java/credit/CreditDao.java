package credit;

import util.DatabaseUtil;

import java.sql.Array;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

public class CreditDao {
    private PreparedStatement pstmt;
    private ResultSet rs;
    private Connection conn;

    // 검색 결과를 편리하게 반환 하기 위한 이너 클래스 제작
    public class ResultCredit {
        public String getCourse_id() {
            return course_id;
        }

        public ResultCredit(String course_id, float olapResult) {
            this.course_id = course_id;
            this.olapResult = olapResult;
        }

        public float getOlapResult() {
            return olapResult;
        }

        public void setOlapResult(float olapResult) {
            this.olapResult = olapResult;
        }

        public void setCourse_id(String course_id) {
            this.course_id = course_id;
        }

        private String course_id;
        private float olapResult;
    }

    // 해당 학생의 평균 평점을 반환
    public float avgStudentCredit(String student_id)
    {
        String SQL = "SELECT credit, grade FROM credit join course using(course_id) WHERE student_id = ?";
        try{
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, student_id);
            rs = pstmt.executeQuery();
            ArrayList<String> grade = new ArrayList<String>();
            ArrayList<Integer> credit = new ArrayList<Integer>();

            // 해당 학생이 들은 전체 학점을 저장
            float allCredit = 0;
            while (rs.next()) {
                allCredit += Integer.parseInt(rs.getString(1));
                // 과목에 대한 학점수와 등급을 각각 저장
                credit.add(Integer.parseInt(rs.getString(1)));
                grade.add(rs.getString(2));
            }

            float result = 0;
            // 반복문을 돌며 학점 * 등급 을 result 에 더해준다
            for(int i=0 ; i<credit.size() ; i++) {
                if(grade.get(i).equals("A+")) {
                    result += (float)credit.get(i)*(4.5);
                } else if (grade.get(i).equals("A0")) {
                    result += (float)credit.get(i)*(4.0);
                }else if (grade.get(i).equals("B+")) {
                    result += (float)credit.get(i)*(3.5);
                }else if (grade.get(i).equals("B0")) {
                    result += (float)credit.get(i)*(3.0);
                }else if (grade.get(i).equals("C+")) {
                    result += (float)credit.get(i)*(2.5);
                }else if (grade.get(i).equals("C0")) {
                    result += (float)credit.get(i)*(2.0);
                }else if (grade.get(i).equals("D0")) {
                    result += (float)credit.get(i)*(1.5);
                } else {
                    result += (float)credit.get(i)*(0.0);
                }
            }

            return result/allCredit; // 마지막에 총 취득점수/총학점 을 반환하여 학점 평균을 반환힌다.
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0; // 오류시 0 반환
    }

    // 과목 통계 함수
    public ArrayList<ResultCredit> olapResultList() {
        String SQL = "with score_table as (" +
                "select course_id, student_id, case when grade = \"A+\" then 4.5" +
                " when grade = \"A0\" then 4" +
                " when grade = \"B+\" then 3.5" +
                " when grade = \"B0\" then 3" +
                " when grade = \"C+\" then 2.5" +
                " when grade = \"C0\" then 2" +
                " when grade = \"D0\" then 1" +
                " else 0" +
                " end as grade_to_score " +
                "from credit)" +
                "," +
                "course_avg as (" +
                "select course_id, avg(grade_to_score) as avg_grade, (select avg(grade_to_score) from score_table) as all_avg " +
                "from score_table " +
                "group by course_id" +
                ")" +
                "," +
                "student_avg as (" +
                "select student_id, avg(grade_to_score) as avg_score_student " +
                "from score_table " +
                "group by student_id" +
                ")" +
                "select course_id, avg(diff_avg) as result " +
                "from(" +
                "select course_id, (avg_score_student-avg_grade) as diff_avg " +
                "from score_table join course_avg using(course_id) join student_avg using (student_id)" +
                ") as diff_t " +
                "group by course_id " +
                "order by result desc " +
                "limit 10";

        try {
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            rs = pstmt.executeQuery();

            ArrayList<ResultCredit> resultCredits = new ArrayList<ResultCredit>();

            while(rs.next()) {
                // 넘어온 정보들을 배열에 저장
                ResultCredit temp = new ResultCredit(rs.getString(1),Float.parseFloat(rs.getString(2)));
                resultCredits.add(temp);
            }

            return resultCredits; // 반환
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null; // 실패시 널값
    }

    // 해당 학생이 과목을 수강 했던적이 있는지 반환
    public int isRetry(String student_id, String course_id) {
        String SQL = "select ifnull(count(*),0) from credit where student_id = ? and course_id = ?";

        try {
            conn = DatabaseUtil.getConnection();
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1,student_id);
            pstmt.setString(2,course_id);
            rs = pstmt.executeQuery();

            if(rs.next()) {
                return Integer.parseInt(rs.getString(1));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0; // 없다면 0 반환
    }
}
