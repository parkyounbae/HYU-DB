<%--
  Created by IntelliJ IDEA.
  User: bag-yunbae
  Date: 2022/11/06
  Time: 1:17 오전
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="enrollment.EnrollmentDao" %>
<%@ page import="hope.HopeDao" %>
<%@ page import="java.io.PrintWriter"%>
<html>
<head>
    <title>Title</title>
</head>
<body>

</body>
<%
    // 수강신청 버튼을 누르면 작동한다.
    request.setCharacterEncoding("UTF-8");
    String class_id = null;
    String current_student_id = null;

    // 입력 받은 값이 null이 아니라면 지역변수에 저장한다.
    if(request.getParameter("class_id")!=null) {
        class_id = (String) request.getParameter("class_id");
    }

    if(request.getParameter("current_student_id") != null) {
        current_student_id = (String) request.getParameter("current_student_id");
    }

    // 두 변수중 하나라도 null 값이 있으면 알림을 보내고 이전화면으로 되돌아 간다.
    if(class_id==null || current_student_id==null) {
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('입력이 안 된 사항이 있습니다.');");
        script.println("history.back()");
        script.println("</script>");
        script.close();
        return;
    }

    // 수강신청에 추가하기 위한 enrollmentDAO 를 생성한다.
    EnrollmentDao enrollmentDao = new EnrollmentDao();
    int result = enrollmentDao.addEnrollment(current_student_id,class_id);
    // 수강신청 결과를 int 값으로 반환 받는다.

    if(result==1) {
        // 결과값이 1 이라면 수강신청에 성공한것이다,
        PrintWriter script = response.getWriter();

        // 이때 희망신청한 과목을 수강신청한 것이면 희망 리스트에서도 삭제해줘야 하므로 hoprDAO 의 deleteHope 함수를 통해 삭제해준다.
        HopeDao hopeDao = new HopeDao();
        int hopeDelete = hopeDao.deleteHope(current_student_id,class_id);

        script.println("<script>");
        // 희망 목록에서도 삭제했으면 해당사항에 대해 알림을 보내준다.
        if(hopeDelete == 1) {
            script.println("alert('수강신청에 성공하셨습니다. 희망목록에서 삭제하였습니다.');");
        } else {
            script.println("alert('수강신청에 성공하셨습니다.');");
        }

        script.println("history.back()");
        script.println("</script>");
        script.close();
        return;
    } else if(result==0){
        // result == 0 이면 새록게 추가 된 값이 없다는 뜻이므로 에러 메세지를 띄운다.
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
