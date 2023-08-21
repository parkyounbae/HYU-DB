<%--
  Created by IntelliJ IDEA.
  User: bag-yunbae
  Date: 2022/11/05
  Time: 3:32 오후
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
    <title>학생 페이지</title>
    <!-- 부트스트랩 css 추가하기 -->
    <link rel="stylesheet" href="./css/bootstrap.min.css">
    <!-- custom css 추가하기 -->
    <link rel="stylesheet" href="./css/custom.css">
    <!-- nav bar style css -->
    <link rel="stylesheet" href="./css/navStyle.css">
</head>
<body>
<%
    // 검색창에서 검색 타입,입력받는 값을 기다린다.
    // 입력을 받았으면 해당 값을 지역 변수에 저장한다.
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
    <header><h1>윤배대학교 : 수강신청 사이트 : 수강 편람</h1></header>
<!--  화면 상단에 네비바를 배치하여 기능페이지 간의 이동이 용이하게 하였다.  -->
    <nav>
        <ul class="nav-container">
            <li class="nav-item"> <a href="">수업 검색</a>
            <li class="nav-item"> <a href="studentTimeTable.jsp">시간표</a>
            <li class="nav-item"> <a href="studentHope.jsp">희망 수업</a>
            <li class="nav-item"> <a href=""><%=(String)session.getAttribute("student_id")%></a>
            <li class="nav-item"> <a href="userLogin.jsp"><로그아웃></로그아웃></a>
        </ul>
    </nav>

<div>
    <!--  유저가 선택한 검색 방식과 키워드를 전송한다. 이후 현재 페이지 리로드한다.  -->
    <form action="./studentMain.jsp" method="get" class="form-inline my-2 my-lg-0">
        <label>검색방법</label>
        <select name="searchType" class="from-control">
            <option value="class_no">class_no</option>
            <option value="course_id">course_id</option>
            <option value="name">name</option>
        </select>
        <input name="searchKeyword" type="text" placeholder="검색어 입력">
        <input type="submit" value="Search">
    </form>

    <h3>검색 결과</h3>
    <div class="container">
        <div class="row">
            <!--  검색 결과를 보여주는 Table  -->
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
                    <th style="text-align: center";>재수강 여부</th>
                    <th style="text-align: center";>수강 신청</th>
                    <th style="text-align: center";>희망 추가</th>
                    <th style="text-align: center";></th>
                </tr>
                </thead>
                <tbody>
                <%
                    ArrayList<Class_tDao.ClassSearchResult> class_ts = new ArrayList<Class_tDao.ClassSearchResult>();
                    class_ts = new Class_tDao().searchClass(searchType,searchKeyword);
                    // class_ts에 입력받은 방식과 키워드로 검색한 결과 리스트를 저장한다.
                    EnrollmentDao enrollmentDao = new EnrollmentDao();
                    CreditDao creditDao = new CreditDao();
                    // 검색 결과에서 누락된 정보를 보충해주기 위해 enrollmentDAO, creditDAO 객체를 생성했다.

                    if(class_ts != null) {
                        // 겸색 결과가 존재할 때 검색 결과만큼 반복문이 돌아간다.
                        for (int i=0 ; i<class_ts.size() ; i++) {
                            class_ts.get(i).setEnrollment_count(enrollmentDao.enrollmentPerson(class_ts.get(i).getClass_id()));
                            // 검색 방식에 따라 신청인원수가 누락될 수 있으므로 따로 함수를 불러와 누락 된 값을 채워준다.
                            Class_tDao.ClassSearchResult resultClass = class_ts.get(i);

                            // 이 과목에 대해 학생이 수강했던 적이 있는지에 대한 표시를 해주기 위해 CreditDAO의 isRetry함수를 호출한다.
                            int retryResult = creditDao.isRetry((String)session.getAttribute("student_id"),class_ts.get(i).getCourse_id());
                            String retryResultString = "";
                            if(retryResult == 0) {
                                retryResultString = "x";
                            } else {
                                retryResultString = "o";
                            }



                            // 반복문 안에 테이블의 row를 작성하는 html을 삽입하여 검색결과의 개수만큼 테이블이 작성되도록 한다.
                            // 각각의 테이블에는 검색 결과가 나타나며 마지막에는 수강신청 버튼과 희망 신청 버튼이 있다.
                            // 수강신청 버튼은 get(URL Parameter) 방식으로 현재 사용자의 id 와 신청할 수업의 class_id 를 get 방식으로 보낸다. 이후 addEnrollmentAction.jsp를 호출한다.
                            // 희망신청 버튼은 get(URL Parameter) 방식으로 현재 사용자의 id 와 신청할 수업의 class_id 를 get 방식으로 보낸다. 이후 addHopeAction.jsp를 호출한다.
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
                                <td><%=retryResultString%></td>
                                <td>
                                    <button type="button" onclick="location.href='./addEnrollmentAction.jsp?class_id=<%=resultClass.getClass_id()%>&current_student_id=<%=(String)session.getAttribute("student_id")%>'">수강신청</button>
                                </td>
                                <td>
                                    <button type="button" onclick="location.href='./addHopeAction.jsp?class_id=<%=resultClass.getClass_id()%>&current_student_id=<%=(String)session.getAttribute("student_id")%>'">희망신청</button>
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
