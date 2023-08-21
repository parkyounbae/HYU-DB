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
<%--  시간표 테이블의 스타일 지정  --%>
    <style>
        table{
            border: 2px solid #d2d2d2;
            border-collapse: collapse;
            font-size: 0.9em;
        }
        th, td{
            border: 1px solid #d2d2d2;
            border-collapse: collapse;
        }
        th{
            height: 5px;
        }
        td {
            width: 75px;
            height: 60px;
        }

    </style>
</head>
<body>
<%
    // 검색값에 대한 정보를 받기 위해
    request.setCharacterEncoding("UTF-8");
    String searchKeyword = "";
    if(request.getParameter("searchKeyword") != null) {
        searchKeyword = (String) request.getParameter("searchKeyword");
    }

%>
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

<%--검색을 위한 텍스트와 버튼--%>
<%--학번을 입력하고 검색버튼을 누르면 학번값이 전송된다. 이후에 adminStudentSearch이 실행된다.--%>
<div>
    <form action="./adminStudentSearch.jsp" method="get" class="form-inline my-2 my-lg-0">
        <input name="searchKeyword" type="text" placeholder="학번 입력">
        <input type="submit" value="조회">
    </form>
<%--검색 결과를 보여주는 테이블--%>
    <h3>검색 결과</h3>
    <div class="container">
        <div class="row">
            <table id="search" class="table">
                <thead>
                <tr>
                    <th style="text-align: center";>학번</th>
                    <th style="text-align: center";>이름</th>
                    <th style="text-align: center";>성적</th>
                    <th style="text-align: center";>지도교수</th>
                    <th style="text-align: center";>상태</th>
                    <th style="text-align: center";>상태 변경</th>
                </tr>
                </thead>
                <tbody>
                <%
                    // 학번을 통해 학생 정보를 받아온다.
                    Student student = new Student();
                    StudentDao studentDao = new StudentDao();
                    student = studentDao.searchStudent(searchKeyword);

                    if (student==null) {
                %> <h1>올바른 학번을 검색해주세요~!</h1> <%
                    } else {
                        // 해당하는 학생이 존재한다면
                        // 그 학생에 대한 학점 정보를 받아온다.
                        CreditDao creditDao = new CreditDao();
                        float studentCredit = creditDao.avgStudentCredit(searchKeyword);

                        // 그 학생의 지도교수 아이디를 통해 지도교수의 이름을 불러온다.
                        LecturerDao lecturerDao = new LecturerDao();
                        String lecturerName = lecturerDao.lecturerName(Integer.toString(student.getLecturer_id()));

                        // 해당 테이블에는 상태를 바꿀수 있는 버튼이 있으며 바꾸고 싶은 상태를 옵션으로 선택한 뒤 변경 버튼을 누르면 해당 학생의 상태가 변경된다.
                %>
                <tr>
                    <td><%= student.getStudent_id()%> </td>
                    <td><%= student.getName()%> </td>
                    <td><%= studentCredit%></td>
                    <td><%= lecturerName%></td>
                    <td><%= student.getCurrent_status()%></td>
                    <td>
                        <form action="changeStatus.jsp" method="post">
                            <input type="hidden" name="student_id" value="<%=student.getStudent_id()%>">
                            <select name="status" class="form-control">
                                <option value="재학">재학</option>
                                <option value="퇴학">퇴학</option>
                                <option value="자퇴">자퇴</option>
                            </select>
                            <input type="submit" value="변경">
                        </form>
                    </td>
                </tr>
                <%
                    }
                %>
                </tbody>

            </table>
        </div>
    </div>
</div>
<%--강의 시간표--%>
<table width=800 height="400" style="color: #121212">
    <caption>▶   강의 시간표  ◀</caption>
    <tr width=19%>
        <th></th>
        <th>월</th>
        <th>화</th>
        <th>수</th>
        <th>목</th>
        <th>금</th>
    </tr>
    <%
        // 작업을 위한 DAO 생성
        EnrollmentDao enrollmentDao = new EnrollmentDao();
        Class_timeDao class_timeDao = new Class_timeDao();
        // 검색한 학생의 학번
        String current_student_id = searchKeyword;
        // 수강신청한 수업 목록을 받아오기 위한 리스트
        ArrayList<String> enrollmentList = new ArrayList<String>();
        enrollmentList = enrollmentDao.enrollmentList(current_student_id);


        // 이하 시간표를 장성하는 부분은 studentTimeTable 의 방식과 동일
        ArrayList<Class_timeDao.TimeInfo>[] arr = new ArrayList[22];
        for(int i=0 ; i<22 ; i++) {
            arr[i] = new ArrayList<Class_timeDao.TimeInfo>();
        }

        if(enrollmentList != null) {
            for(int i=0 ; i<enrollmentList.size() ; i++) {
                Class_timeDao.TimeInfo enrollmentTimeList = class_timeDao.classTime(enrollmentList.get(i));
                int beginTime = enrollmentTimeList.stringTimeToInt();
                if(beginTime >= 900) {
                    beginTime -= 900;
                } else {
                    beginTime += 300;
                }
                int index = beginTime/100*2 + (beginTime%100)/30;

                for(int spanCount=0 ; spanCount<enrollmentTimeList.spanCount() ; spanCount++) {
                    arr[index+spanCount].add(enrollmentTimeList);
                }

            }
        }

        for(int i=900 ; i<2000 ; i = i+50) {
    %>
    <tr>
        <th><%=i/100 + ":" + (i%100)/50*3 + "0"%></th>
        <%
            int tIndex = ((i/100)-9)*2 + ((i%100)/50);
            for(int day=1 ; day<6 ; day++) {
                int table_result = -1;

                for(int table=0 ; table<arr[tIndex].size() ; table++) {
                    if(Integer.parseInt(arr[tIndex].get(table).getDayOfWeek())==day) {
                        System.out.println("week  " + arr[tIndex].get(table).getDayOfWeek());
                        table_result = table;
                    }
                }
                if(table_result != -1) {
        %>
        <td style="background-color: #0dcaf0"><%=arr[tIndex].get(table_result).getName()%></td>
        <%
        } else {
        %> <td></td> <%
            }
        }
    %>
    </tr>

    <%
        }

    %>
</table>

<!-- jquery javascript -->
<script src="./js/jquery.min.js"></script>
<!-- popper javascript -->
<script src="./js/pooper.js"></script>
<!-- bootstrap javascript -->
<script src="./js/bootstrap.min.js"></script>

</body>
</html>
