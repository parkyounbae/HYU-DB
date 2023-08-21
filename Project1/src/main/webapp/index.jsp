<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>JSP - Hello World</title>
</head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

<title>수강신청 사이트</title>
<!-- 부트스트랩 css 추가하기 -->
<link rel="stylesheet" href="./css/bootstrap.min.css">
<!-- custom css 추가하기 -->
<link rel="stylesheet" href="./css/custom.css">
<body>
<h1><%= "수강신청 사이트" %>
</h1>
<br/>

<form action="userLogin.jsp" method ='post'.>
    <h3><%= "로그인"%></h3>
    <div class="form-group">
        <input type="text" class="form-control" placeholder="아이디" name="id_from_web">
    </div>
    <div class="form-group">
        <input type="password" class="form-control" placeholder="비밀번호" name="password_from_web">
    </div>
    <input type="submit" class="btn btn-primary form-control" value="로그인">
<!-- 입력받은 아이디와 비밀번호를 post 형식으로 보내고 userlogin.jsp 를 호출한다.    -->
</form>

<!-- jquery javascript -->
<script src="./js/jquery.min.js"></script>
<!-- popper javascript -->
<script src="./js/pooper.js"></script>
<!-- bootstrap javascript -->
<script src="./js/bootstrap.min.js"></script>

</body>
</html>