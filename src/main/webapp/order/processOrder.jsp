<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.*" %>
<%@page import="java.sql.*" %>
<%@page import="DBPKG.JDBConnect"%>

<%
String orderType = request.getParameter("orderType");
String orderData = request.getParameter("orderData");

// orderData를 JSON 형태로 파싱하고 필요한 처리 로직 구현
// 이 부분에서 데이터베이스에 저장하거나 다른 처리 로직을 추가할 수 있습니다.

out.println("주문 유형: " + orderType);
out.println("주문 데이터: " + orderData);

// 데이터 처리 후 성공 메시지 등을 응답으로 보낼 수 있습니다.
%>
