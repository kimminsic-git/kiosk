	<%@page language="java" contentType="text/html; charset=UTF-8"
	    pageEncoding="UTF-8"%>
	<%@page import="java.util.*"%>
	<%@page import="java.sql.*"%>
	<%@page import="DBPKG.JDBConnect"%>
	<!DOCTYPE html>
	<html>
	<head>
	<meta charset="UTF-8">
	<title>재고 목록</title>
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
	<link rel="stylesheet" href="style.css">
	</head>
	<body>
	<section>
	    <div class="Menu-window">
	        <h2>재고 목록</h2>
	        <div class="menulist">
	            <ul class="menu-list">
	                <%
	                JDBConnect db = new JDBConnect();
	                Connection conn = null;
	                PreparedStatement psmt = null;
	                ResultSet rs = null;
	
	                int pageSize = 16; // 페이지당 항목 수
	                int currentPage = 1; // 현재 페이지
	                if (request.getParameter("page") != null) {
	                    currentPage = Integer.parseInt(request.getParameter("page"));
	                }
	                if (currentPage < 1) {
	                    currentPage = 1; // 페이지 번호가 1 미만일 경우 1로 설정
	                }
	
	                try {
	                    conn = db.getConnection();
	                    String sql = "SELECT * FROM ( " +
	                                 "SELECT a.*, ROWNUM rnum FROM ( " +
	                                 "SELECT * FROM remain_2024_10 ORDER BY cofid " +
	                                 ") a WHERE ROWNUM <= ? " +
	                                 ") WHERE rnum > ?";
	
	                    psmt = conn.prepareStatement(sql);
	                    psmt.setInt(1, currentPage * pageSize); // 최대 ROWNUM
	                    psmt.setInt(2, (currentPage - 1) * pageSize); // 시작 ROWNUM
	
	                    rs = psmt.executeQuery();
	
	                    while (rs.next()) {
	                    	String cofid = rs.getString("cofid");
	                        String cofname = rs.getString("cofname");
	                        String price = rs.getString("price");
	                        String sellable = rs.getString("sellable");
	                        if (sellable.equals("Y")) {
	                            sellable = "판매중";
	                        } else if (sellable.equals("N")) {
	                            sellable = "매진";
	                        }
	                        String remaincount = rs.getString("remaincount");
	                %>
	                <li>
	                    <div class="menu-details">
	                        <h3><a href="edit.jsp?cofid=<%=cofid %>"><%=cofid %>.<%=cofname%></a></h3>
	                        <p>가격: <%=price%>원</p>
	                        <p><%=sellable%></p>
	                        <p>남은 갯수: <%=remaincount%></p>
	                    </div>
	                </li>
	                <%
	                    }
	
	                    // 총 항목 수 조회
	                    psmt = conn.prepareStatement("SELECT COUNT(*) AS total FROM remain_2024_10");
	                    rs = psmt.executeQuery();
	                    int totalItems = 0;
	                    if (rs.next()) {
	                        totalItems = rs.getInt("total");
	                    }
	
	                    // 총 페이지 수 계산
	                    int totalPages = (int) Math.ceil(totalItems / (double) pageSize);
	                    if (totalPages == 0) totalPages = 1; // 페이지 수가 0이면 1페이지로 설정
	                %>
	            </ul>
	
	            <div class="pagination">
	                <%
	                for (int i = 1; i <= totalPages; i++) {
	                    if (i == currentPage) {
	                %>
	                <span><%= i %></span> <!-- 현재 페이지 표시 -->
	                <%
	                    } else {
	                %>
	                <a href="?page=<%=i%>"><%= i %></a> <!-- 숫자 링크 -->
	                <%
	                    }
	                }
	                %>
	            </div>
	            <%
	            } catch (SQLException e) {
	                e.printStackTrace(); // 개발 중에만 사용
	            } finally {
	                if (rs != null)
	                    try {
	                        rs.close();
	                    } catch (SQLException ignore) {
	                    }
	                if (psmt != null)
	                    try {
	                        psmt.close();
	                    } catch (SQLException ignore) {
	                    }
	                if (conn != null)
	                    try {
	                        conn.close();
	                    } catch (SQLException ignore) {
	                    }
	            }
	            %>
	        </div>
	        <div style="text-align: center;">
		        <a class="nav-link" href="insert.jsp">메뉴 추가</a>
		        <a class="nav-link" href="list.jsp">주문 확인</a>
	        </div>
	    </div>
	</section>
	</body>
	</html>
