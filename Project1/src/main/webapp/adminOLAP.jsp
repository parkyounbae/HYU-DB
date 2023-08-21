<%--
  Created by IntelliJ IDEA.
  User: bag-yunbae
  Date: 2022/11/06
  Time: 10:43 오후
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
<%@ page import="credit.CreditDao" %>
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
        <li class="nav-item"> <a href="">수업 검색</a>
        <li class="nav-item"> <a href="adminMakeClass.jsp">설강페이지</a>
        <li class="nav-item"> <a href="adminStudentSearch.jsp">학생정보조회</a>
        <li class="nav-item"> <a href="adminOLAP.jsp">과목통계</a>
        <li class="nav-item"> <a href=""><%=(String)session.getAttribute("admin_id")%></a>
        <li class="nav-item"> <a href="userLogin.jsp"><로그아웃></로그아웃></a>
    </ul>
</nav>
<%--과목 통계를 보여주기 위한 사이트이다. 별도의 입력은 없다.--%>
<div>
    <h1>짜게주는 수업 TOP 10</h1>
    <div class="container">
        <div class="row">
            <table id="rank" class="table">
                <thead>
                <tr>
                    <th style="text-align: center";>등수</th>
                    <th style="text-align: center";>class_id</th>
                    <th style="text-align: center";>diff</th>
                </tr>
                </thead>
                <tbody>
                <%
                    //CreditDao의 olapResultList함수를 통해 통계 결과 값을 불러온다.
                    CreditDao creditDao = new CreditDao();
                    ArrayList<CreditDao.ResultCredit> arr = new ArrayList<CreditDao.ResultCredit>();
                    arr = creditDao.olapResultList();

                    for(int i=0 ; i<arr.size() ; i++) {
                        %>
                <tr>
                    <td style="text-align: center"><%=i+1 + "등"%></td>
                    <td style="text-align: center"><%=arr.get(i).getCourse_id()%></td>
                    <td style="text-align: center"><%=arr.get(i).getOlapResult()%></td>
                </tr>
                <%
                    }
                %>


                </tbody>
            </table>
        </div>
    </div>
</div>

</body>
</html>
