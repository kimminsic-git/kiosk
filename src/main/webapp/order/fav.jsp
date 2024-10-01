<%@page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="java.sql.*"%>
<%@page import="DBPKG.JDBConnect"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>인기제품 목록</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <%@ include file="header.jsp"%>
    <section>
        <div class="Menu-window">
            <h2>인기제품 목록</h2>
            <div class="menulist">
                <ul class="menu-list">
                    <%
                    JDBConnect db = new JDBConnect();
                    Connection conn = null;
                    PreparedStatement psmt = null;
                    ResultSet rs = null;

                    int pageSize = 6; // 페이지당 항목 수
                    int currentPage = 1; // 현재 페이지
                    if (request.getParameter("page") != null) {
                        currentPage = Integer.parseInt(request.getParameter("page"));
                    }
                    if (currentPage < 1) {
                        currentPage = 1; // 페이지 번호가 1 미만일 경우 1로 설정
                    }

                    try {
                        conn = db.getConnection();

                        // 모든 항목 가져오기 (카테고리 없이)
                        String sql = "SELECT m.*, r.remaincount FROM ( " + 
                                     "SELECT a.*, ROWNUM rnum FROM ( " +
                                     "SELECT * FROM MENU_2024_10 WHERE cofsell >= ? ORDER BY cofsell DESC " + 
                                     ") a WHERE ROWNUM <= ? " +
                                     ") m LEFT JOIN remain_2024_10 r ON m.cofnum = r.cofid " +
                                     "WHERE r.remaincount IS NOT NULL AND r.remaincount >= 0";

                        psmt = conn.prepareStatement(sql);
                        psmt.setInt(1, 100); // 최소 판매량
                        psmt.setInt(2, currentPage * pageSize); // 최대 ROWNUM

                        rs = psmt.executeQuery();

                        while (rs.next()) {
                            int cofnum = rs.getInt("cofnum");
                            String menuName = rs.getString("cofname");
                            String price = rs.getString("price");
                            String temp = rs.getString("tem");
                            int remainCount = rs.getInt("remaincount");
                            String availability = remainCount > 0 ? "" : "매진"; // 매진 체크
                    %>
                    <li>
                            <a href="javascript:void(0);" class="<%=availability.isEmpty() ? "" : "disabled"%>" 
       							onclick="<%=availability.isEmpty() ? "loadOrderDetails('" + cofnum + "');" : "" %>">
                            <div class="Menu-img" style="background-image: url('../image/<%=menuName%>.jpg');"></div>
                            <div class="menu-details">
                                <h3><%=menuName%></h3>
                                <p>가격: <%=price%></p>
                                <% if (!temp.equals("Hot/Ice")) { %>
                                    <p>온도: <%=temp%></p>
                                <% } %>
                                <p style="color: red;"><%=availability%></p> <!-- 매진 표시 -->
                            </div>
                        </a>
                    </li>
                    <%
                        }

                        // 총 항목 수 조회
                        psmt = conn.prepareStatement("SELECT COUNT(*) AS total FROM MENU_2024_10 WHERE cofsell >= ?");
                        psmt.setInt(1, 100);
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
                        <strong>●</strong>
                    <%
                        } else {
                    %>
                        <a href="?page=<%=i%>">○</a>
                    <%
                        }
                    }
                    %>
                </div>
                
                <%
                } catch (SQLException e) {
                    e.printStackTrace(); // 개발 중에만 사용
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                    if (psmt != null) try { psmt.close(); } catch (SQLException ignore) {}
                    if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
                }
                %>
            </div>
            <div class="SubMenu-window">
                <h2>주문 내역</h2>
                <div id="order-details">
                    <!-- 주문 세부사항이 여기에 로드됩니다 -->
                    <jsp:include page="order.jsp" />
                </div>
            </div>
        </div>
    </section>

    <script>
        // loadOrderDetails 함수를 전역으로 설정
        window.loadOrderDetails = function(cofnum) {
            const currentQuantity = selectedCofnums[cofnum] || 0;
            selectedCofnums[cofnum] = currentQuantity + 1; // 수량 증가

            // AJAX 호출
            $.ajax({
                url: 'saveOrder.jsp',
                type: 'POST',
                data: {
                    cofnums: JSON.stringify(selectedCofnums)
                },
                success: function(response) {
                    console.log('주문이 저장되었습니다:', response);
                    $('#order-details').load('order.jsp', function() {
                        updateOrderDetails(); // 주문 내역 업데이트
                    });
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    console.error('주문 저장 중 오류:', textStatus, errorThrown);
                    alert('주문 저장 중 오류가 발생했습니다.');
                }
            });
        };
    </script>
</body>
</html>
