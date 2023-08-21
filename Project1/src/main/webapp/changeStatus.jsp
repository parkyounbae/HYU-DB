<%--
  Created by IntelliJ IDEA.
  User: bag-yunbae
  Date: 2022/11/07
  Time: 12:29 오후
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="enrollment.Enrollment" %>
<%@ page import="enrollment.EnrollmentDao" %>
<%@ page import="hope.Hope" %>
<%@ page import="hope.HopeDao" %>
<%@ page import="java.io.PrintWriter"%>
<%@ page import="student.StudentDao" %>
<html>
<head>
    <title>Title</title>
</head>
<body>

</body>
<%
    // 학생의 상태를 바꿀때 호출
    request.setCharacterEncoding("UTF-8");
    String status = null;
    String student_id = null;

    // 입력 된 값이 있다면 저장
    if(request.getParameter("status")!=null) {
        status = (String) request.getParameter("status");
    }

    if(request.getParameter("student_id") != null) {
        student_id = (String) request.getParameter("student_id");
    }

    // 둘 중에 하나라도 null 값이면 오류
    if(status==null || student_id==null) {
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('입력이 안 된 사항이 있습니다.');");
        script.println("history.back()");
        script.println("</script>");
        script.close();
        return;
    }

    //studentDao의 changeStatus을 통해 학생의 상태를 바꿈
    StudentDao studentDao = new StudentDao();
    // 바꾼 결과 값을 저장
    int result =studentDao.changeStatus(student_id,status);

    if(result==1) {
        // 결과 값이 1 이라면 성공
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('변경에 성공하셨습니다.');");
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

