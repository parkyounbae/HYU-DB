<%--
  Created by IntelliJ IDEA.
  User: bag-yunbae
  Date: 2022/11/06
  Time: 1:48 오후
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
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.lang.reflect.Array" %>
<!-- 학생이 수강신청한 수업들에 대한 시간표와 그 수업들에 대한 정보를 확인 할 수 있는 페이지 -->
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

  <!-- 밑에 생성할 테이블에 대한 스타일을 미리 지정해준다.  -->
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
<header><h1>윤배대학교 : 수강신청 사이트 : 시간표</h1></header>
<nav>
  <ul class="nav-container">
    <li class="nav-item"> <a href="studentMain.jsp">수업 검색</a>
    <li class="nav-item"> <a href="">시간표</a>
    <li class="nav-item"> <a href="studentHope.jsp">희망 수업</a>
    <li class="nav-item"> <a href=""><%=(String)session.getAttribute("student_id")%></a>
  </ul>
</nav>
<!-- 시간표를 위한 테이블을 생성한다. -->
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
    EnrollmentDao enrollmentDao = new EnrollmentDao();
    Class_timeDao class_timeDao = new Class_timeDao();
    // 수강신청 목록과 수업의 시간을 불러오기 위해 Class_timeDAO, EnrollmentDAO 생성
    String current_student_id = (String) session.getAttribute("student_id");
    // 수강신청시에 값으로 학번을 넘겨주기위해 세션에 저장되어있는 현재 접속중인 학생의 학번을 저장해둔다.

    ArrayList<String> enrollmentList = new ArrayList<String>();
    enrollmentList = enrollmentDao.enrollmentList(current_student_id);
    // 현재 학생이 수강신청한 수업들의 class_id 를 저장한다.

    // 수업을 요일/시간 별로 저장하기 위한 2차원 배열을 생성한다.
    // 시간은 30분 단위로 쪼개서 저장한다.
    // arr[0] : 9시에 수업중, arr[1] : 9:30에 수업중, arr[2] : 10시에 수업중 ...
    // 예를 들면 arr[3][2] = 10시30분 에 수업을 진행중인 수업들 중 두번째
    ArrayList<Class_timeDao.TimeInfo>[] arr = new ArrayList[23];
    for(int i=0 ; i<23 ; i++) {
      arr[i] = new ArrayList<Class_timeDao.TimeInfo>();
    }

    // 수강신청한 수업이 있을 때
    if(enrollmentList != null) {
      // 우리가 수강 신청한 수업들의 정보를 아까 정의한 arr 에 맞추어 넣어줘야한다.
      for(int i=0 ; i<enrollmentList.size() ; i++) {
        // class_timeDAO 의 classTime 함수는 수업의 이름, 시작시간, 끝나는시간, 요일 정보를 담은 객체(TimeInfo)를 반환
        Class_timeDao.TimeInfo enrollmentTimeList = class_timeDao.classTime(enrollmentList.get(i));
        // 수업 시작 시간을 인트 형식으로 바꾸어 주는 함수
        // 09:00 -> 900 , 11:00 -> 1100
        int beginTime = enrollmentTimeList.stringTimeToInt();

        if(beginTime>=600 && beginTime <900){
          // 시작시간이 6:00시 이후이면 온라인 수업 취급
          // 이때 저장 형식이 오전 오후를 구분하지 못하기 때문에 900보다 작아야 한다는 조건 추가 (900은 아침9시)
          System.out.println("online");
        } else if (Integer.parseInt(enrollmentTimeList.getDayOfWeek()) > 5) {
          // 마찬가지로 day_of_week 값이 6 이상이면 온라인 수업 (6은 토요일)
          System.out.println("online");
        } else {
          // 위의 조건문을 통과 하고 들어옴 -> 평일, 오후6시 이전에 시작하는 수업

          // 시간들을 우리가 전해둔 배열의 인덱스로 변환
          if(beginTime >= 900) {
            // 900보다 큰건 오전9시 ~ 오전 11시30분
            // 900씩 빼면 0에서  230 으로 변한다
            beginTime -= 900;
          } else {
            // 900 보다 작다는건 오후12시이후 이다.
            // 위에서 11시 30분이 230 이므로 0 시인 00 이 300이 되도록 300을 더해준다.
            beginTime += 300;
          }
          // 위의 과정이 지나면 beginTime 값이 오전 9시부턴 순차적으로
          // 0 30 100 130 200 230 300 .. 이런식으로 변한다.

          int index = beginTime/100*2 + (beginTime%100)/30;
          // 위에서 변환한 값을 또 다시 인덱스 값으로 변환
          // 9:00 = 0, 9:30 = 1 , 10:00 = 2 ... 이런식으로 순차적으로 변한다.

          // spanCounr 함수는 각 수업시간에 따라 몇칸을 차지해야한지 반환한다. (30분 기준)
          // 2시간 수업 = 4칸, 1시간30분 수업 = 3칸
          for(int spanCount=0 ; spanCount<enrollmentTimeList.spanCount() ; spanCount++) {
            arr[index+spanCount].add(enrollmentTimeList);
            // 시작시간 : index + 수업 길이 : span
            // 9시에 시작하는 한시간 짜리 수업
            // arr[0+0] , arr[0+1] 이렇게 두칸에 수업이 추가되게 된다.
          }
        }
      }
    }

    // 시간표 제작을 위해 900(오전 9시) 2000(오후 8시) 까지 반복문을 돈다.
    // 시간은 30분 단위이지만 루프문 증가는 50씩으로 설정하였다.
    for(int i=900 ; i<2000 ; i = i+50) {
      %>
      <tr>
        <th><%=i/100 + ":" + (i%100)/50*3 + "0"%></th>
        <%
          // 반복문의 i 값을 위에서 지장한 인덱스에 맞게 변환한다.
          // 9:00 = 0, 9:30 = 1 , 10:00 = 2 ... 이런식
          int tIndex = ((i/100)-9)*2 + ((i%100)/50);

          // 해당 시간대에 대해 월-금 을 조회한다.
          for(int day=1 ; day<6 ; day++) {
            int table_result = -1;

            // 해당 시간대에 저장되어있는 요소들을 탐색하면서
            for(int table=0 ; table<arr[tIndex].size() ; table++) {
              if(Integer.parseInt(arr[tIndex].get(table).getDayOfWeek())==day) {
                // 현재 검색하고 있는 요일에 해당하는 수업이 있을때
                table_result = table;
              }
            }
            if(table_result != -1) {
              // 현재 검색하고 있는 요일에 해당하는 수업이 있을때 그 수업에 대한 정보 표시
              %>
                <td style="background-color: #0dcaf0"><%=arr[tIndex].get(table_result).getName()%></td>
              <%
            } else {
              // 없다면 빈칸 표시
               %> <td></td> <%
            }
          }
          %>
      </tr>

      <%
    }

  %>
</table>

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
        <th style="text-align: center";>요일</th>
        <th style="text-align: center";>신청 인원</th>
        <th style="text-align: center";>수강 정원</th>
        <th style="text-align: center";>강의실 건물</th>
        <th style="text-align: center";>강의실 호수</th>
        <th style="text-align: center";>수강 신청</th>
      </tr>
      </thead>
      <tbody>
      <%
        //메인의 검색 테이블과 같은 구조이지만 이미 수강신청을 진행 한 수업이므로 수강신청 버튼 대신에 수강취소 버튼이 있다.
        Class_tDao class_tDao = new Class_tDao();

        // 수강신청한 수업들이 있다면. (정보는 시간표 작성할때 이미 받아옴)
        if(enrollmentList != null) {
          ArrayList<Class_tDao.ClassSearchResult> class_ts = new ArrayList<Class_tDao.ClassSearchResult>();

          // 수강신청한 수업에 대한 검색 결과를 배열에 저장
          for(int i=0 ; i<enrollmentList.size() ; i++) {
            ArrayList<Class_tDao.ClassSearchResult> temp = class_tDao.searchClass("class_id",enrollmentList.get(i));
            if(temp != null) {
              class_ts.addAll(temp);
            }
          }

          if(class_ts != null) {
            for (int i=0 ; i<class_ts.size() ; i++) {
              // 아까와 마찬가지로 수강신청인원을 따로 넣어준다.
              class_ts.get(i).setEnrollment_count(enrollmentDao.enrollmentPerson(class_ts.get(i).getClass_id()));
              Class_tDao.ClassSearchResult resultClass = class_ts.get(i);
              // 수강 신청한 과목 개수만큼 루프문 반복하며 정보를 담은 테이블을 제작한다.

      %>
      <tr>
        <td><%= (i+1) %></td>
        <td><%= resultClass.getClass_no()%> </td>
        <td><%= resultClass.getCourse_id()%> </td>
        <td><%= resultClass.getClass_t_name()%></td>
        <td><%= resultClass.getLecturer_name()%></td>
        <td><%= resultClass.getBegin_time() + "~" + resultClass.getEnd_time()%></td>
        <td><%= resultClass.getDay_of_week()%></td>
        <td><%= resultClass.getEnrollment_count()%></td>
        <td><%= resultClass.getPerson_max()%></td>
        <td><%= resultClass.getBuilding()%></td>
        <td><%= resultClass.getRoom()%></td>
        <td>
          <button type="button" onclick="location.href='./deleteEnrollmentAction.jsp?class_id=<%=resultClass.getClass_id()%>&current_student_id=<%=session.getAttribute("student_id")%>'">수강취소</button>
        </td>
      </tr>
      <%
              // 수강삭제 버튼을 클릭하면 해당 수업의 class_id 와 현재 접속한 학생의 학번을 get으로 보낸다. 이후 DeleteEnrollmentAction을 실행한다.
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
