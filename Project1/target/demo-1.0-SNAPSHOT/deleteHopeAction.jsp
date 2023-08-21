<%--
  Created by IntelliJ IDEA.
  User: bag-yunbae
  Date: 2022/11/06
  Time: 11:02 오전
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
  // 희망 삭제 버튼을 눌렀을 때 작동
  request.setCharacterEncoding("UTF-8");
  String class_id = null;
  String current_student_id = null;

  // get 으로 넘어온 값을 받아서 저장
  if(request.getParameter("class_id")!=null) {
    class_id = (String) request.getParameter("class_id");
  }

  if(request.getParameter("current_student_id") != null) {
    current_student_id = (String) request.getParameter("current_student_id");
  }

  // 둘중에 하나라도 null 값이라면 오류 반환
  if(class_id==null || current_student_id==null) {
    PrintWriter script = response.getWriter();
    script.println("<script>");
    script.println("alert('입력이 안 된 사항이 있습니다.');");
    script.println("history.back()");
    script.println("</script>");
    script.close();
    return;
  }

  // HopeDAO 의 deleteHope 함수를 통해 삭제 결과 int 로 받음
  HopeDao hopeDao = new HopeDao();
  int result = hopeDao.deleteHope(current_student_id,class_id);

  if(result==1) {
    // 결과 값이 1이면 성공적으로 삭제를 한 것이므로 성공 알림
    PrintWriter script = response.getWriter();
    script.println("<script>");
    script.println("alert('희망 강의에서 삭제하였습니다.');");
    script.println("history.back()");
    script.println("opener.location.reload()");
    script.println("</script>");
    script.close();
    return;
  } else if(result==0){
    // 결과 값이면 삭제 실패
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
