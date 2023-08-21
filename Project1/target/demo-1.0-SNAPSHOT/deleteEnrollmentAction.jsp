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
<html>
<head>
    <title>Title</title>
</head>
<body>

</body>
<%
    // 수강취소 버튼을 눌렀을때 실행됨
    request.setCharacterEncoding("UTF-8");
    String class_id = null;
    String current_student_id = null;

    // 넘어오는 값들을 기다리고 NULL 값이 아닐때 지역변수에 저장한다.
    if(request.getParameter("class_id")!=null) {
        class_id = (String) request.getParameter("class_id");
    }

    if(request.getParameter("current_student_id") != null) {
        current_student_id = (String) request.getParameter("current_student_id");
    }

    // 둘 중에 하나라도 Null 값이 있으면 오류를 반환한다.
    if(class_id==null || current_student_id==null) {
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('입력이 안 된 사항이 있습니다.');");
        script.println("history.back()");
        script.println("</script>");
        script.close();
        return;
    }

    EnrollmentDao enrollmentDao = new EnrollmentDao();
    int result = enrollmentDao.deleteEnrollment(current_student_id,class_id);
    // 수강 취소를 진행한 EnrollmentDAO 를 생성
    // 함수 실행 결과를 result 에 Int 값으로 반환 받는다.

    if(result==1) {
        // 결과값이 1이면 1개가 잘 삭제된것이므로 수강 삭제에 성공했다는 메시지 출력
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('수강삭제에 성공하셨습니다.');");
        script.println("history.back()");
        script.println("opener.location.reload()");
        script.println("</script>");
        script.close();
        return;
    } else if(result==0){
        // 아니면 에러 문구 출력
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
