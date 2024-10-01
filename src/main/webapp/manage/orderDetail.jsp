<%@page import="java.sql.Date"%>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.*" %>
<%@page import="java.sql.*" %>
<%@page import="DBPKG.JDBConnect" %>
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
        <h1>주문 상세목록</h1>
        <table border="1">
            <thead>
                <tr>
                    <th>주문 ID</th>
                    <th>상세 ID</th>
                    <th>메뉴 이름</th>
                    <th>주문 수량</th>
                </tr>
            </thead>
            <tbody>
                <%
                // orderid 파라미터 받기
                String orderid = request.getParameter("orderId");
                
                // 데이터베이스 연결
                JDBConnect db = new JDBConnect();
                try (Connection conn = db.getConnection()) {
                    // 주문 목록 조회 쿼리
                    String query = "SELECT a.orderid, a.ordeid, b.cofname, a.count FROM orderde_2024_10 a JOIN Menu_2024_10 b ON a.cofnum = b.cofnum WHERE a.orderid = ? ORDER BY a.orderid";
                    try (PreparedStatement stmt = conn.prepareStatement(query)) {
                        stmt.setString(1, orderid); // orderid를 쿼리에 설정
                        try (ResultSet rs = stmt.executeQuery()) {
                            // 결과를 테이블에 출력
                            while (rs.next()) {
                                int orderId = rs.getInt("orderid");
                                String ordeid = rs.getString("ordeid");
                                String cofname = rs.getString("cofname");
                                int count = rs.getInt("count");
                %>
                <tr>
                    <td><%= orderId %></td>
                    <td><%= ordeid %></td>
                    <td><%= cofname %></td>
                    <td><%= count %>개</td>
                </tr>
                <%
                            }
                        }
                    }
                } catch (SQLException e) {
                    out.println("<tr><td colspan='4'>데이터를 불러오는 중 오류가 발생했습니다.</td></tr>");
                }
                %>
            </tbody>
        </table>
        <div style="text-align: center;">
		    <a class="nav-link" href="list.jsp">뒤로가기</a>
		   	<a class="nav-link" href="checking.jsp">메뉴리스트</a>
	    </div>
    </div>
</body>
</html>
