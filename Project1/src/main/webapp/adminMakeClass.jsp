<%--
  Created by IntelliJ IDEA.
  User: bag-yunbae
  Date: 2022/11/06
  Time: 10:42 오후
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
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>관리자 페이지</title>
    <!-- 부트스트랩 css 추가하기 -->
    <link rel="stylesheet" href="./css/bootstrap.min.css">
    <!-- custom css 추가하기 -->
    <link rel="stylesheet" href="./css/custom.css">
    <!-- nav bar style css -->
    <link rel="stylesheet" href="./css/navStyle.css">
</head>
<body>
<header><h1>윤배대학교 : 관리자모드</h1></header>
<nav>
    <ul class="nav-container">
        <li class="nav-item"> <a href="adminMain.jsp">수업 검색</a>
        <li class="nav-item"> <a href="adminMakeClass.jsp">설강페이지</a>
        <li class="nav-item"> <a href="adminStudentSearch.jsp">학생정보조회</a>
        <li class="nav-item"> <a href="adminOLAP.jsp">과목통계</a>
        <li class="nav-item"> <a href=""><%=(String)session.getAttribute("admin_id")%></a>
        <li class="nav-item"> <a href="userLogin.jsp"><로그아웃></로그아웃></a>
    </ul>
</nav>
<%--새로운 수업을 설강할수 있는 페이지 이다.--%>
<%--각각의 필드에 데이터를 입력한 뒤에 제출 버튼을 누르면 makeClassAction 을 실행한다. --%>
<form action="makeClassAction.jsp" method="post">
    <div>
        <label>class_id : </label>
        <input type="text" name="class_id">
    </div>

    <div>
        <label>class_no : </label>
        <input type="text" name="class_no" >
    </div>

    <div>
        <label>course_id : </label>
        <input type="text" name="course_id" >
    </div>

    <div>
        <label>name : </label>
        <input type="text" name="name" >
    </div>

    <div>
        <label>major_id : </label>
        <input type="text" name="major_id" >
    </div>

    <div>
        <label>class_year : </label>
        <input type="text" name="class_year" >
    </div>

    <div>
        <label>credit : </label>
        <input type="text" name="credit" >
    </div>

    <div>
        <label>lecturer_id : </label>
        <input type="text" name="lecturer_id">
    </div>

    <div>
        <label>person_max : </label>
        <input type="text" name="person_max">
    </div>

    <div>
        <label>opened : </label>
        <input type="text" name="opened">
    </div>

    <div>
        <label>room_id : </label>
        <input type="text" name="room_id">
    </div>
    <div>
        <label>period : </label>
        <input type="text" name="period">
    </div>
    <div>
        <label>begin_time : </label>
        <input type="text" name="begin_time">
    </div>
    <div>
        <label>end_time : </label>
        <input type="text" name="end_time">
    </div>
    <div>
        <label>day_of_week : </label>
        <input type="text" name="day_of_week">
    </div>
    <input type="submit" value="등록">
</form>

</body>
</html>
