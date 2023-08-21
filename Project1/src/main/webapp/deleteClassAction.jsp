<%--
  Created by IntelliJ IDEA.
  User: bag-yunbae
  Date: 2022/11/06
  Time: 8:22 오후
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="enrollment.Enrollment" %>
<%@ page import="enrollment.EnrollmentDao" %>
<%@ page import="hope.Hope" %>
<%@ page import="hope.HopeDao" %>
<%@ page import="java.io.PrintWriter"%>
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

    // 입력값이 있다면 저장
    if(request.getParameter("class_id")!=null) {
        class_id = (String) request.getParameter("class_id");
    }

    // 입력 값이 없다면 오류
    if(class_id==null) {
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('입력이 안 된 사항이 있습니다.');");
        script.println("history.back()");
        script.println("</script>");
        script.close();
        return;
    }

    // Class_tDao의 deleteClass 를 통해 과목 삭제를 시도한다.
    Class_tDao class_tDao = new Class_tDao();
    // 과목 삭제 결과 값을 저장한다.
    int result = class_tDao.deleteClass(class_id);

    // 과목 삭제시 신청목록, 희망 강의, 시간 에서도 삭제 해야함
    EnrollmentDao enrollmentDao = new EnrollmentDao();
    Class_timeDao class_timeDao = new Class_timeDao();
    HopeDao hopeDao = new HopeDao();
    // 각각의 삭제 결과를 저장
    int hopeResult = hopeDao.classDeleted(class_id);
    int enrollResult = enrollmentDao.classDeleted(class_id);
    int timeResult = class_timeDao.classDeleted(class_id);

    if(result==1) {
        // 결과값이 1 이면 삭제 성공
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('강의 삭제에 성공하셨습니다.');");
        script.println("history.back()");
        script.println("opener.location.reload()");
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
