<%@page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="java.sql.*"%>
<%@page import="DBPKG.JDBConnect"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>음료 목록</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link rel="stylesheet" href="style.css">
    <style>
        .disabled {
            pointer-events: none; /* 클릭 비활성화 */
            opacity: 0.5; /* 시각적으로 비활성화 표시 */
        }
    </style>
</head>
<body>
    <%@ include file="header.jsp"%>

	<%
	//제목 설정
	String title = "음료 목록";
	// 카테고리 설정 (예: Tea)
	String category = "Drink"; 
	%>
	
	<jsp:include page="menuList.jsp">
		<jsp:param name="title" value="<%= title %>"/>
    	<jsp:param name="category" value="<%= category %>"/>
    </jsp:include>
</body>
</html>
