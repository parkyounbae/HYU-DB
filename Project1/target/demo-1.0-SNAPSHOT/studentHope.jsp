<%--
  Created by IntelliJ IDEA.
  User: bag-yunbae
  Date: 2022/11/05
  Time: 9:40 오후
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="class_t.Class_t" %>
<%@ page import="class_t.Class_tDao" %>
<%@ page import="class_time.Class_timeDao" %>
<%@ page import="class_time.Class_time" %>
<%@ page import="enrollment.EnrollmentDao" %>
<%@ page import="enrollment.Enrollment" %>
<%@ page import="lecturer.LecturerDao" %>
<%@ page import="lecturer.Lecturer" %>
<%@ page import="student.Student" %>
<%@ page import="student.StudentDao" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="hope.HopeDao" %>
<%--학생이 추가한 희망수업을 표시하는 페이지--%>
<html>
<head>
  <meta charset="UTF-8">
    <title>희망 수업 페이지</title>
  <!-- 부트스트랩 css 추가하기 -->
  <link rel="stylesheet" href="./css/bootstrap.min.css">
  <!-- custom css 추가하기 -->
  <link rel="stylesheet" href="./css/custom.css">
  <!-- nav bar style css -->
  <link rel="stylesheet" href="./css/navStyle.css">
</head>
<body>
<header><h1>윤배대학교 : 수강신청 사이트 : 희망 수업</h1></header>
<nav>
  <ul class="nav-container">
    <li class="nav-item"> <a href="studentMain.jsp">수업 검색</a>
    <li class="nav-item"> <a href="studentTimeTable.jsp">시간표</a>
    <li class="nav-item"> <a href="">희망 수업</a>
    <li class="nav-item"> <a href=""><%=(String)session.getAttribute("student_id")%></a>
    <li class="nav-item"> <a href="userLogin.jsp"><로그아웃></로그아웃></a>
  </ul>
</nav>

<%-- 희망신청한 수업들을 보여주는 테이블, 수강신청을 진행하는 버튼과 희망 목록에서 삭제하는 버튼이 있다. --%>
<div class="container">
  <div class="row">
    <table class="table">
      <thead>
      <tr>
        <th style="text-align: center";></th>
        <th style="text-align: center";>수업 번호</th>
        <th style="text-align: center";>학수 번호</th>
        <th style="text-align: center";>교과목 명</th>
        <th style="text-align: center";>교강사 이름</th>
        <th style="text-align: center";>수업 시간</th>
        <th style="text-align: center";>신청 인원</th>
        <th style="text-align: center";>수강 정원</th>
        <th style="text-align: center";>강의실 건물</th>
        <th style="text-align: center";>강의실 호수</th>
        <th style="text-align: center";>수강 신청</th>
        <th style="text-align: center";>희망 삭제</th>
        <th style="text-align: center";></th>
      </tr>
      </thead>
      <tbody>
      <%
        // 현재 접속하고 있는 학생의 학번을 세션에서 불러옴
        String current_student_id = (String) session.getAttribute("student_id");
        // 현재 학생이 희망목록에 추가한 수업들의 class_id 를 hopeList 함수를 통해 불러와 저장
        ArrayList<String> strings = new ArrayList<String>();
        strings = new HopeDao().hopeList(current_student_id);

        Class_tDao class_tDao = new Class_tDao();
        EnrollmentDao enrollmentDao = new EnrollmentDao();

        // 희망 목록에 담아둔 수업들이 있다면
        if(strings != null) {
          ArrayList<Class_tDao.ClassSearchResult> class_ts = new ArrayList<Class_tDao.ClassSearchResult>();
          // 해당 수업들에 대한 검색 결과들을 저장
          for(int i=0 ; i<strings.size() ; i++) {
            ArrayList<Class_tDao.ClassSearchResult> temp = class_tDao.searchClass("class_id",strings.get(i));
            if(temp != null) {
              class_ts.addAll(temp);
            }
          }

          if(class_ts != null) {
            // 해당 수업들에 대한 검색 결과들을 반복문을 돌며 테이블 작성
            for (int i=0 ; i<class_ts.size() ; i++) {
              // 수강신청인원 수정
              class_ts.get(i).setEnrollment_count(enrollmentDao.enrollmentPerson(class_ts.get(i).getClass_id()));
              Class_tDao.ClassSearchResult resultClass = class_ts.get(i);

              // 수강신청 버튼을 누르면 해당 수업의 class_id 와 학생의 학번이 get 으로 보내진다. 이후 addEnrollmentAction.jsp 를 실행한다.
              // 희망삭제 버튼을 누르면 해당 수업의 class_id 와 학생의 학번이 get 으로 보내진다. 이후 deleteHopeAction.jsp 를 실행한다.

      %>
      <tr>
        <td><%= (i+1) %></td>
        <td><%= resultClass.getClass_no()%> </td>
        <td><%= resultClass.getCourse_id()%> </td>
        <td><%= resultClass.getClass_t_name()%></td>
        <td><%= resultClass.getLecturer_name()%></td>
        <td><%= resultClass.getBegin_time() + "~" + resultClass.getEnd_time()%></td>
        <td><%= resultClass.getEnrollment_count()%></td>
        <td><%= resultClass.getPerson_max()%></td>
        <td><%= resultClass.getBuilding()%></td>
        <td><%= resultClass.getRoom()%></td>
        <td>
          <button type="button" onclick="location.href='./addEnrollmentAction.jsp?class_id=<%=resultClass.getClass_id()%>&current_student_id=<%=session.getAttribute("student_id")%>'">수강신청</button>
        </td>
        <td>
          <button type="button" onclick="location.href='./deleteHopeAction.jsp?class_id=<%=resultClass.getClass_id()%>&current_student_id=<%=session.getAttribute("student_id")%>'">희망삭제</button>
        </td>
      </tr>
      <%
            }
          }
        }
      %>
      </tbody>

    </table>
  </div>
</div>
</body>
</html>
