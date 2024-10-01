<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Insert title here</title>
    <link rel="stylesheet" href="headerstyle.css">
    <script>
        window.onload = function() {
            var currentPath = window.location.pathname.split('/').pop(); // 현재 경로의 마지막 부분만 가져오기
            var links = document.querySelectorAll('nav a');
            links.forEach(function(link) {
                if (link.getAttribute('href') === currentPath) {
                    link.classList.add('active');
                }
            });
        };
    </script>
</head>
<body>
<div class="position">
	<button type="button" onclick="location.href='../index.jsp'"></button>
	<jsp:include page="sessionTimer.jsp" />
</div>    
    <h1 style="margin-top: 20px;">키오스크</h1>
    
    <nav>
        <p><a href="fav.jsp">인기메뉴</a></p>
        <p><a href="coffee.jsp">커피</a></p>
        <p><a href="drink.jsp">스무디/에이드/주스</a></p>
        <p><a href="prafe.jsp">프라페</a></p>
        <p><a href="tea.jsp">티</a></p>
        <p><a href="desert.jsp">디저트</a></p>
    </nav>
</body>
</html>
