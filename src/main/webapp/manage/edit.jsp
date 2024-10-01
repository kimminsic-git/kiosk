<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="DBPKG.JDBConnect"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.SQLException"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>재고 수정</title>
    <link rel="stylesheet" href="style.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script>
        function previewImage(event) {
            var reader = new FileReader();
            reader.onload = function() {
                var output = document.getElementById('imagePreview');
                output.src = reader.result;
                output.style.display = 'block';
            }
            reader.readAsDataURL(event.target.files[0]);
        }
    </script>
</head>
<body>
    <section>
        <div class="Menu-window">
            <h2>재고 수정</h2>
            <div class="menulist-edit">
                <ul class="menu">
                    <%
                    JDBConnect db = new JDBConnect();
                    Connection conn = null;
                    PreparedStatement psmt = null;
                    ResultSet rs = null;
                    ResultSet rsCategory = null;

                    String cofid = request.getParameter("cofid");

                    try {
                        conn = db.getConnection();
                        String sql = "SELECT * FROM remain_2024_10 a JOIN Menu_2024_10 b ON b.cofnum = a.cofid WHERE a.cofid = ?";
                        psmt = conn.prepareStatement(sql);
                        psmt.setString(1, cofid);
                        rs = psmt.executeQuery();

                        String categorySql = "SELECT DISTINCT catego FROM Menu_2024_10";
                        PreparedStatement psmtCategory = conn.prepareStatement(categorySql);
                        rsCategory = psmtCategory.executeQuery();
                        List<String> categories = new ArrayList<>();
                        while (rsCategory.next()) {
                            categories.add(rsCategory.getString("catego"));
                        }

                        while (rs.next()) {
                            String cofids = rs.getString("cofid");
                            String cofname = rs.getString("cofname");
                            String price = rs.getString("price");
                            String sellable = rs.getString("sellable").equals("Y") ? "판매중" : "매진";
                            String remaincount = rs.getString("remaincount");
                            String catego = rs.getString("catego");
                            String tem = rs.getString("tem");
                            String cofsell = rs.getString("cofsell");
                    %>
                    <li>
                        <form action="updateServlet" method="POST" enctype="multipart/form-data">
                            <div class="menu-details">
                                <p>메뉴번호: <input type="text" name="cofid" value="<%=cofids%>" readonly></p>
                                <input type="hidden" name="oldCofname" value="<%=cofname%>" readonly>
                                <p>새 이름: <input type="text" name="cofname" value="<%=cofname%>" required></p>
                                <p>가격: <input type="text" name="price" value="<%=price%>" required> 원</p>
                                <p>상태: 
                                    <select name="sellable">
                                        <option value="Y" <%=sellable.equals("판매중") ? "selected" : ""%>>판매중</option>
                                        <option value="N" <%=sellable.equals("매진") ? "selected" : ""%>>매진</option>
                                    </select>
                                </p>
                                <p>남은 갯수: <input type="number" name="remaincount" value="<%=remaincount%>" required></p>
                                <p>카테고리: 
                                    <select name="catego">
                                        <%
                                        for (String category : categories) {
                                        %>
                                        <option value="<%=category%>" <%=catego.equals(category) ? "selected" : ""%>><%=category%></option>
                                        <%
                                        }
                                        %>
                                    </select>
                                </p>
                                <p>온도: 
                                    <select name="tem">
                                        <option value="Hot" <%=tem.equals("Hot") ? "selected" : ""%>>Hot</option>
                                        <option value="Ice" <%=tem.equals("Ice") ? "selected" : ""%>>Ice</option>
                                        <option value="Hot/Ice" <%=tem.equals("Hot/Ice") ? "selected" : ""%>>해당없음</option>
                                    </select>
                                </p>
                                <p>판매량: <input type="number" name="sellingcount" value="<%=cofsell%>" required></p>
                                <p>기존 사진:<br><img src="../image/<%=cofname%>.jpg" alt="기존 이미지" style="max-width: 200px; max-height: 200px;"/></p>
                                <p>사진 업로드: <input type="file" name="productImage" accept="image/*" onchange="previewImage(event)"></p>
                                <img id="imagePreview" src="" alt="이미지 미리보기" style="display:none; max-width: 200px; max-height: 200px;"/>
                                <div>
                                    <input type="submit" name="action" value="수정">
                                    <input type="hidden" name="cofid123" value="<%=cofids%>"> <!-- 여기서 cofid 전달 -->
                                    <input type="button" value="삭제" onclick="location.href='deleteItem.jsp?cofid=<%=cofids%>&cofname=<%=cofname%>';">
                                </div>		
                            </div>
                        </form>
                    </li>
                    <%
                        }
                    } catch (SQLException e) {
                        System.out.println("DB 오류: " + e.getMessage());
                    } finally {
                        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                        if (psmt != null) try { psmt.close(); } catch (SQLException ignore) {}
                        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
                    }
                    %>
                </ul>
            </div>
            <div style="text-align: center;">
            	<button class="nav-link" onclick="location.href='checking.jsp'">메뉴로 돌아가기</button>
            </div>
        </div>
    </section>
</body>
</html>
