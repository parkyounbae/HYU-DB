<%--
  Created by IntelliJ IDEA.
  User: bag-yunbae
  Date: 2022/11/05
  Time: 2:01 오후
  To change this template use File | Settings | File Templates.
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="student.StudentDao"%>
<%@ page import="student.Student"%>
<%@ page import="admin.Admin" %>
<%@ page import="admin.AdminDao" %>
<%@ page import="java.io.PrintWriter"%>

<html>
<head>
    <title>Title</title>
</head>
<body>

</body>
<%
    request.setCharacterEncoding("UTF-8");
    String id_from_web = null;
    String password_from_web = null;

    // login요청을 받았는데 이미 유저 혹은 어드민에 대한 세션 값이 있다면 로그아웃 해주기
    // 로그인 된 상태의 각각의 메인페이지에서 로그아웃 버튼을 누르면 여기서 걸려 로그아웃이 된다.
    // 로그아웃 이후 초기 로그인 화면으로 돌아감
    if(session.getAttribute("student_id")!=null || session.getAttribute("admin_id")!=null) {
        session.invalidate();
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('logout.');");
        script.println("</script>");

        response.sendRedirect("index.jsp");
        script.close();
    }

    // 입력 받은 값을 지역 변수에 저장한다.
    if(request.getParameter("id_from_web") != null) {
        id_from_web = (String) request.getParameter("id_from_web");
    }
    if(request.getParameter("password_from_web") != null) {
        password_from_web = (String) request.getParameter("password_from_web");
    }

    // 둘중에 하나라도 null 값이면 입력이 이루어지지 않은 것이므로 오류 알림 띄우고 로그인 화면으로 돌아감
    if(id_from_web==null || password_from_web==null) {
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('입력이 안 된 사항이 있습니다.');");
        script.println("location.href = 'index.jsp';");
        script.println("</script>");
        script.close();
        return;
    }

    StudentDao studentDao = new StudentDao();
    AdminDao adminDao = new AdminDao();
    // 각각의 DAO 를 통해서 로그인 함수 실행
    //로그인 성공 결과를 Int 값으로 반환 받는다.
    int studentResult = studentDao.login(id_from_web,password_from_web);
    int adminResult = adminDao.login(id_from_web,password_from_web);

    // studentResult = 1 이면 학생 로그인에 성공
    // 학생 페이지로 들어간다.
    if (studentResult == 1) {
        PrintWriter script = response.getWriter();
        session.setAttribute("student_id",id_from_web);
        script.println("<script>");
        script.println("alert('학생 로그인에 성공했습니다.');");
        script.println("location.href = 'studentMain.jsp';");
        script.println("</script>");
        script.close();
        return;
    } else if(adminResult == 1) {
        // adminResult = 1 이면 관리자 로그인에 성공
        // 관리자 페이지로 들어간다.
        PrintWriter script = response.getWriter();
        session.setAttribute("admin_id",id_from_web);
        script.println("<script>");
        script.println("alert('관리자 로그인에 성공했습니다.');");
        script.println("location.href = 'adminMain.jsp';");
        script.println("</script>");
        script.close();
        return;
    } else if (studentResult == 0 || adminResult == 0){
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('wrong password');");
        script.println("history.back()");
        script.println("</script>");
        script.close();
        return;
    } else if (studentResult == -1 || adminResult == -1) {
        // 반환 값이 -1이면 틀린 아이디가 입력된것
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('wrong id');");
        script.println("history.back()");
        script.println("</script>");
        script.close();
        return;
    }else if (studentResult == -2 || adminResult == -2) {
        // 에러일때
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('database error');");
        script.println("history.back()");
        script.println("</script>");
        script.close();
        return;
    }

    %>
</html>
