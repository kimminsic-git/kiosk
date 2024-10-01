<%@page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="java.sql.*"%>
<%@page import="DBPKG.JDBConnect"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>디저트 목록</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <%@ include file="header.jsp"%>

	<%
	//제목 설정
	String title = "디저트 목록";
	// 카테고리 설정 (예: Tea)
	String category = "Dessert"; 
	%>
	
	<jsp:include page="menuList.jsp">
		<jsp:param name="title" value="<%= title %>"/>
    	<jsp:param name="category" value="<%= category %>"/>
    </jsp:include>
</body>
</html>
