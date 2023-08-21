<%--
  Created by IntelliJ IDEA.
  User: bag-yunbae
  Date: 2022/11/07
  Time: 2:13 오전
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="hope.Hope" %>
<%@ page import="hope.HopeDao" %>
<%@ page import="java.io.PrintWriter"%>
<%@ page import="room.RoomDao" %>
<%@ page import="class_t.Class_tDao" %>
<%@ page import="class_time.Class_timeDao" %>
<html>
<head>
    <title>Title</title>
</head>
<body>

</body>
<%
    request.setCharacterEncoding("UTF-8");
    String class_id = null;
    String class_no = null;
    String course_id = null;
    String name = null;
    String major_id = null;
    String class_year = null;
    String credit = null;
    String lecturer_id = null;
    String person_max = null;
    String opened = null;
    String room_id = null;

    // 입력 값으로 넘어온 값들을 저장한다.
    if(request.getParameter("class_no")!=null) {
        class_no = (String) request.getParameter("class_no");
    }
    if(request.getParameter("class_id")!=null) {
        class_id = (String) request.getParameter("class_id");
    }
    if(request.getParameter("course_id")!=null) {
        course_id = (String) request.getParameter("course_id");
    }
    if(request.getParameter("name")!=null) {
        name = (String) request.getParameter("name");
    }
    if(request.getParameter("major_id")!=null) {
        major_id = (String) request.getParameter("major_id");
    }
    if(request.getParameter("class_year")!=null) {
        class_year = (String) request.getParameter("class_year");
    }
    if(request.getParameter("credit")!=null) {
        credit = (String) request.getParameter("credit");
    }
    if(request.getParameter("lecturer_id")!=null) {
        lecturer_id = (String) request.getParameter("lecturer_id");
    }
    if(request.getParameter("person_max")!=null) {
        person_max = (String) request.getParameter("person_max");
    }
    if(request.getParameter("opened")!=null) {
        opened = (String) request.getParameter("opened");
    }
    if(request.getParameter("room_id")!=null) {
        room_id = (String) request.getParameter("room_id");
    }

    String period = null;
    String begin_time = null;
    String end_time = null;
    String day_of_week = null;

    if(request.getParameter("period")!=null) {
        period = (String) request.getParameter("period");
    }
    if(request.getParameter("begin_time")!=null) {
        begin_time = (String) request.getParameter("begin_time");
    }
    if(request.getParameter("end_time")!=null) {
        end_time = (String) request.getParameter("end_time");
    }
    if(request.getParameter("day_of_week")!=null) {
        day_of_week = (String) request.getParameter("day_of_week");
    }

    // 입력되지 않은 값이 있다면 오류를 반환한다.
    if(period==null||begin_time==null||end_time==null||day_of_week==null||class_id==null || class_no == null || course_id == null || name == null || major_id == null || class_year == null || credit == null || lecturer_id == null || person_max == null || opened == null || room_id == null) {
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('입력이 안 된 사항이 있습니다.');");
        script.println("history.back()");
        script.println("</script>");
        script.close();
        return;
    }

    // 룸 아이디를 통해 해당 강의실의 수용 인원을 불러온다.
    RoomDao roomDao = new RoomDao();
    String person_max_of_room = roomDao.getMaxPerson(room_id);

    // 존재하지 않는 강의실이면 에러 반환
    if(person_max_of_room == null) {
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('error');");
        script.println("history.back()");
        script.println("</script>");
        script.close();
        return;
    }

    // 선택한 강의실의 수용인원보다 수강인원이 많으면 오류 반환
    if(Integer.parseInt(person_max) > Integer.parseInt(person_max_of_room)) {
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('강의실이 작습니다.');");
        script.println("history.back()");
        script.println("</script>");
        script.close();
        return;
    }

    // Class_tDao의 makeNewClass을 통해 새로 만든 강의 넣기
    Class_tDao class_tDao = new Class_tDao();
    int result = class_tDao.makeNewClass(class_id,  class_no,  course_id,  name,  major_id,  class_year,  credit,  lecturer_id,  person_max,  opened,  room_id);
    Class_timeDao class_timeDao = new Class_timeDao();

    int timeResult = 0;
    if(result==1) {
        // 강의 입력이 성공하였다면 class_time 에더 해당 강의의 시간 추가
        timeResult = class_timeDao.addClassTime(class_id,period,begin_time,end_time,day_of_week);
    }

    if(timeResult == 0) {
        // 강의 추가는 성공했지만 시간추가에 실패한 경우 추가했던 강의는 다시 삭제
        class_tDao.deleteClass(class_id);
    }

    if(result==1 && timeResult==1) {
        // 둘다 결과 값이 1이어야 성공 반환
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('설강 완료.');");
        script.println("history.back()");
        script.println("</script>");
        script.close();
        return;
    } else if(result==0){
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('error');");
        script.println("history.back()");
        script.println("</script>");
        script.close();
        return;
    }
%>
</html>
