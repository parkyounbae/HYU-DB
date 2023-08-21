<%--
  Created by IntelliJ IDEA.
  User: bag-yunbae
  Date: 2022/11/06
  Time: 2:13 오전
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
    // 희망신청 버튼을 누르면 작동한다.
    request.setCharacterEncoding("UTF-8");
    String class_id = null;
    String current_student_id = null;

    // 입력 받은 값이 존재한다면 해당 값을 지역변수에 저장한다.
    if(request.getParameter("class_id")!=null) {
        class_id = (String) request.getParameter("class_id");
    }

    if(request.getParameter("current_student_id") != null) {
        current_student_id = (String) request.getParameter("current_student_id");
    }

    // 둘중에 하나라도 null 값이 있다면 입력이 안된 사항이 있음을 알리고 이전 페이지로 되돌아간다.
    if(class_id==null || current_student_id==null) {
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('입력이 안 된 사항이 있습니다.');");
        script.println("history.back()");
        script.println("</script>");
        script.close();
        return;
    }

    // 희망 목록에 추가하기 위해 HopeDAO 를 생성한다.
    HopeDao hopeDao = new HopeDao();
    int result = hopeDao.addHope(current_student_id,class_id);
    // 희망추가의 결과 값을 int 로 전달받는다.

    if(result==1) {
        // 결과값이 1이면 1개를 추가한 것이므로 성공메시지를 띄우고 이전페이지로 돌아간다.
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('희망 강의에 추가하였습니다.');");
        script.println("history.back()");
        script.println("</script>");
        script.close();
        return;
    } else if(result==0){
        // 결과값이 0이면 추가에 실패한것이므로 에러메시지를 띄운다.
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
