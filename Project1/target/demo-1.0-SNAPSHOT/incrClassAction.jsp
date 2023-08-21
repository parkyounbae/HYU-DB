<%--
  Created by IntelliJ IDEA.
  User: bag-yunbae
  Date: 2022/11/06
  Time: 10:46 오후
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="enrollment.Enrollment" %>
<%@ page import="enrollment.EnrollmentDao" %>
<%@ page import="hope.Hope" %>
<%@ page import="hope.HopeDao" %>
<%@ page import="java.io.PrintWriter"%>
<%@ page import="class_t.Class_tDao" %>
<html>
<head>
    <title>Title</title>
</head>
<body>

</body>
<%
    request.setCharacterEncoding("UTF-8");
    String class_id = null;
    String num_to_incr = null;

    // 입력받은 값이 넘어오면 저장한다.
    if(request.getParameter("class_id")!=null) {
        class_id = (String) request.getParameter("class_id");
    }

    if(request.getParameter("num_to_incr") != null) {
        num_to_incr = (String) request.getParameter("num_to_incr");
    }

    // 둘중에 하나라도 Null 값이라면 오류를 반환한다.
    if(class_id==null || num_to_incr==null) {
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('입력이 안 된 사항이 있습니다.');");
        script.println("history.back()");
        script.println("</script>");
        script.close();
        return;
    }

    // Class_tDAO 의 incrClass 함수를 통해 증원을 시도한다.
    Class_tDao class_tDao = new Class_tDao();
    // 증원 결과 값을 result에 저장받는다.
    int result = class_tDao.incrClass(num_to_incr,class_id);

    if(result==1) {
        // 결과 값이 1이라면 증원 성공 메시지를 보낸다.
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('증원에 성공하셨습니다.');");
        script.println("history.back()");
        script.println("</script>");
        script.close();
        return;
    } else if(result==0){
        // 결과 값이 0 이면 에러메시지를 출력한다.
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