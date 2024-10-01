<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="DBPKG.JDBConnect"%>

<%
	String title = request.getParameter("title");
%>
    <section>
        <div class="Menu-window">
            <h2><%=title %></h2>
            <div class="menulist">
                <ul class="menu-list">
<%
    String category = request.getParameter("category");
    int pageSize = 6; // 페이지당 항목 수
    int currentPage = 1; // 현재 페이지
    if (request.getParameter("page") != null) {
        currentPage = Integer.parseInt(request.getParameter("page"));
    }
    if (currentPage < 1) {
        currentPage = 1; // 페이지 번호가 1 미만일 경우 1로 설정
    }

    JDBConnect db = new JDBConnect();
    Connection conn = null;
    PreparedStatement psmt = null;
    ResultSet rs = null;

    try {
        conn = db.getConnection();
        String sql = "SELECT m.*, r.remaincount,r.sellable FROM ( " +
                     "SELECT a.*, ROWNUM rnum FROM ( " +
                     "SELECT * FROM MENU_2024_10 WHERE catego = ? ORDER BY cofsell DESC " +
                     ") a WHERE ROWNUM <= ? " +
                     ") m LEFT JOIN remain_2024_10 r ON m.cofnum = r.cofid " +
                     "WHERE r.remaincount IS NOT NULL AND r.remaincount >= 0 " +
                     "AND rnum > ?";

        int startRow = (currentPage - 1) * pageSize;
        int endRow = currentPage * pageSize;

        psmt = conn.prepareStatement(sql);
        psmt.setString(1, category);
        psmt.setInt(2, endRow); // 최대 ROWNUM
        psmt.setInt(3, startRow); // 시작 ROWNUM

        rs = psmt.executeQuery();

        while (rs.next()) {
            int cofnum = rs.getInt("cofnum");
            String menuName = rs.getString("cofname");
            String price = rs.getString("price");
            String temp = rs.getString("tem");
            int remainCount = rs.getInt("remaincount");
            String sellable = rs.getString("sellable");
            String availability = (remainCount > 0 && sellable.equals("Y")) ? " " : "매진"; // 매진 체크
%>
            <li>
                <a href="javascript:void(0);" class="<%= availability.equals("매진") ? "disabled" : "" %>" 
                   onclick="<%= availability.equals("매진") ?  "" : "loadOrderDetails('" + cofnum + "');" %>">
                    <div class="Menu-img" style="background-image: url('../image/<%= menuName %>.jpg');"></div>
                    <div class="menu-details">
                        <h3><%= menuName %></h3>
                        <p>가격: <%= price %></p>
                        <p><%=temp.equals("Hot/Ice") ? "" : "온도:"+temp %></p>
                        <p style="color: red;height: 21px;"><%= availability %></p> <!-- 매진 표시 -->
                    </div>
                </a>
            </li>
<%
        }

        // 총 항목 수 조회
        psmt = conn.prepareStatement("SELECT COUNT(*) AS total FROM MENU_2024_10 WHERE catego = ?");
        psmt.setString(1, category);
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
                <a href="?category=<%= category %>&page=<%= i %>">○</a>
<%
            }
        }
%>
    </div>
<%
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        // 자원 해제
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
                    $('#order-details').load('order.jsp'); // 주문 내역 업데이트
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    console.error('주문 저장 중 오류:', textStatus, errorThrown);
                    alert('주문 저장 중 오류가 발생했습니다.');
                }
            });
        };
    </script>
