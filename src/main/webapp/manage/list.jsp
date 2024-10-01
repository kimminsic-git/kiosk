<%@page import="java.sql.Date"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="DBPKG.JDBConnect" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>주문 목록</title>
    <link rel="stylesheet" href="liststyles.css"> <!-- CSS 파일 연결 -->
</head>
<body>
    <div class="container">
        <h1>주문 목록</h1>
        <table border="1">
            <thead>
                <tr>
                    <th>주문 ID</th>
                    <th>주문 날짜</th>
                    <th>총 가격</th>
                    <th>포장 유형</th>
                    <th>상세보기</th>
                </tr>
            </thead>
            <tbody>
                <%
                // 데이터베이스 연결
                JDBConnect db = new JDBConnect();
                try (Connection conn = db.getConnection()) {
                    // 주문 목록 조회 쿼리
                    String query = "SELECT orderid, orderdat, totalprice, packing FROM Order_2024_10 ORDER BY orderid";
                    try (PreparedStatement stmt = conn.prepareStatement(query);
                         ResultSet rs = stmt.executeQuery()) {
                        // 결과를 테이블에 출력
                        while (rs.next()) {
                            int orderId = rs.getInt("orderid");
                            Date orderDate = rs.getDate("orderdat");
                            int totalPrice = rs.getInt("totalprice");
                            String packing = rs.getString("packing");
                            if (packing.equals("mall")) {
                            	packing = "매장";
                            }else if (packing.equals("pack")) {
                            	packing = "포장";
                            }else {
                            	packing = "입력오류";
                            }
                %>
                <tr>
                    <td><%= orderId %></td>
                    <td><%= orderDate %></td>
                    <td><%= totalPrice %> 원</td>
                    <td><%= packing %></td>
                    <td><a href="orderDetail.jsp?orderId=<%= orderId %>">상세보기</a></td>
                </tr>
                <%
                        }
                    }
                } catch (SQLException e) {
                    out.println("<tr><td colspan='5'>데이터를 불러오는 중 오류가 발생했습니다.</td></tr>");
                }
                %>
            </tbody>
        </table>
        <div style="text-align: center;">
        	<a class="nav-link" href="checking.jsp">메뉴리스트</a>
        </div>
    </div>
</body>
</html>
