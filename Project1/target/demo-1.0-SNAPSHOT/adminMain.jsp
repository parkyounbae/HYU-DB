<%--
  Created by IntelliJ IDEA.
  User: bag-yunbae
  Date: 2022/11/06
  Time: 10:35 오후
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
<%--  관리자의 메인페이지 이다. 수업들을 검색할 수 있으며 해당 검색 결과흫 통해 폐강 또는 증원을 할 수 있다.   --%>
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
<%
    // 검색창에 입력한 값과 검색 타입을 받기 위해
    request.setCharacterEncoding("UTF-8");
    String searchType = "";
    String searchKeyword = "";
    if(request.getParameter("searchKeyword") != null) {
        searchKeyword = (String) request.getParameter("searchKeyword");
    }
    if(request.getParameter("searchType") != null) {
        searchType = (String) request.getParameter("searchType");
    }
%>
<header><h1>윤배대학교 : 관리자모드</h1></header>
<%--학생페이지와 마찬가지로 네비바를 두어 기능간 이동을 편하게--%>
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

<%--강의를 유형별로 검색할수 있는 검색 필드--%>
<%--입력 후 버튼을 누르면 입력 값이 제출된다.--%>
<div>
    <form action="./adminMain.jsp" method="get" class="form-inline my-2 my-lg-0">
        <label>검색방법</label>
        <select name="searchType" class="from-control">
            <option value="class_no">class_no</option>
            <option value="course_id">course_id</option>
            <option value="name">name</option>
        </select>
        <input name="searchKeyword" type="text" placeholder="검색어 입력">
        <input type="submit" value="Search">
    </form>
<%--검색 결과를 보여주는 표--%>
<%--해당 표에서 폐강 및 증원이 가능하다.--%>
    <h3>검색 결과</h3>
    <div class="container">
        <div class="row">
            <table id="search" class="table">
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
                    <th style="text-align: center";>폐강</th>
                    <th style="text-align: center";>증원</th>
                    <th style="text-align: center";></th>
                </tr>
                </thead>
                <tbody>
                <%
                    // 검색 키워드와 검색 타입을 통해 검색 값을 리스트에 저장
                    ArrayList<Class_tDao.ClassSearchResult> class_ts = new ArrayList<Class_tDao.ClassSearchResult>();
                    class_ts = new Class_tDao().searchClass(searchType,searchKeyword);

                    EnrollmentDao enrollmentDao = new EnrollmentDao();
                    // 검색 결과가 존재 한다면 반복문을 돌며 해당 수업에 대한 정보를 표로 작성한다.
                    if(class_ts != null) {
                        for (int i=0 ; i<class_ts.size() ; i++) {
                            // 수강 인원 수정
                            class_ts.get(i).setEnrollment_count(enrollmentDao.enrollmentPerson(class_ts.get(i).getClass_id()));
                            Class_tDao.ClassSearchResult resultClass = class_ts.get(i);

                            // 관리자의 검색 결과에서는 폐강과 증원이 가능하다
                            // 폐강 버튼을 누르면 해당 강의의 class_id 를 보내며 deleteClassAction을 실행한다.
                            // 증원할  인원수를 입력 한 뒤에 증원 버튼을 누르면 인원수 와 class_id 를 보내며 incrClassAction 을 실행한다.
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
                        <button type="button" onclick="location.href='./deleteClassAction.jsp?class_id=<%=resultClass.getClass_id()%>'">폐강</button>
                    </td>
                    <td>
                        <form action="incrClassAction.jsp" method="get">
                            <input type="text" class="form-control" placeholder="숫자" name="num_to_incr">
                            <input type="hidden" name="class_id" value="<%=resultClass.getClass_id()%>">
                            <input type="submit" class="btn btn-primary form-control" value="제출">
                        </form>
                    </td>
                </tr>
                <%
                        }
                    }
                %>
                </tbody>

            </table>
        </div>
    </div>
</div>

<!-- jquery javascript -->
<script src="./js/jquery.min.js"></script>
<!-- popper javascript -->
<script src="./js/pooper.js"></script>
<!-- bootstrap javascript -->
<script src="./js/bootstrap.min.js"></script>


</body>
</html>
