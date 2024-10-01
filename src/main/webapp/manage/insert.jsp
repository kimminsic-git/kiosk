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
    <title>재고 추가</title>
    <link rel="stylesheet" href="style.css">
    <script>
        function previewImage(event) {
            const imagePreview = document.getElementById('imagePreview');
            const file = event.target.files[0];
            const reader = new FileReader();

            reader.onload = function() {
                imagePreview.src = reader.result;
                imagePreview.style.display = 'block';
            };

            if (file) {
                reader.readAsDataURL(file);
            } else {
                imagePreview.src = "";
                imagePreview.style.display = 'none';
            }
        }
    </script>
</head>
<body>
    <section>
        <div class="Menu-window">
            <h2>재고 추가</h2>
            <div class="menulist-edit">
                <ul class="menu">
                    <li>
                        <form action="updateProcessing" method="POST" enctype="multipart/form-data">
                            <p>제품 번호:
                                <%
                                JDBConnect db = new JDBConnect();
                                Connection conn = null;
                                PreparedStatement psmt = null;
                                ResultSet rs = null;
                                String productId = "";

                                try {
                                    conn = db.getConnection();
                                    String idSql = "SELECT MAX(cofnum) + 1 AS new_id FROM Menu_2024_10";
                                    psmt = conn.prepareStatement(idSql);
                                    rs = psmt.executeQuery();
                                    if (rs.next()) {
                                        productId = rs.getString("new_id");
                                    }
                                } catch (SQLException e) {
                                    out.println("<script>alert('DB 오류: " + e.getMessage() + "');</script>");
                                } finally {
                                    if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                                    if (psmt != null) try { psmt.close(); } catch (SQLException ignore) {}
                                    if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
                                }
                                %>
                                <input type="text" name="cofid" value="<%=productId%>" readonly>
                            </p>
                            <p>이름: <input type="text" name="cofname" required></p>
                            <p>가격: <input type="text" name="price" required> 원</p>
                            <p>상태: 
                                <select name="sellable">
                                    <option value="Y">판매중</option>
                                    <option value="N">매진</option>	
                                </select>
                            </p>
                            <p>남은 갯수: <input type="number" name="remaincount" value="0" required></p>
                            <p>카테고리: 
                                <select name="catego">
                                    <%
                                    JDBConnect db2 = new JDBConnect();
                                    Connection conn2 = null;
                                    PreparedStatement psmt2 = null;
                                    ResultSet rsCategory = null;

                                    try {
                                        conn2 = db2.getConnection();
                                        String categorySql = "SELECT DISTINCT catego FROM Menu_2024_10";
                                        psmt2 = conn2.prepareStatement(categorySql);
                                        rsCategory = psmt2.executeQuery();
                                        List<String> categories = new ArrayList<>();
                                        while (rsCategory.next()) {
                                            categories.add(rsCategory.getString("catego"));
                                        }
                                        for (String category : categories) {
                                    %>
                                    <option value="<%=category%>"><%=category%></option>
                                    <%
                                        }
                                    } catch (SQLException e) {
                                        out.println("<script>alert('DB 오류: " + e.getMessage() + "');</script>");
                                    } finally {
                                        if (rsCategory != null) try { rsCategory.close(); } catch (SQLException ignore) {}
                                        if (psmt2 != null) try { psmt2.close(); } catch (SQLException ignore) {}
                                        if (conn2 != null) try { conn2.close(); } catch (SQLException ignore) {}
                                    }
                                    %>
                                </select>
                            </p>
                            <p>온도: 
                                <select name="tem">
                                    <option value="Hot">Hot</option>
                                    <option value="Ice">Ice</option>
                                    <option value="Hot/Ice">해당없음</option>
                                </select>
                            </p>
                            <p>사진 업로드: 
                                <input type="file" name="productImage" accept="image/*" required onchange="previewImage(event)">
                            </p>
                            <img id="imagePreview" src="" alt="이미지 미리보기" style="display:none; max-width: 200px; max-height: 200px;"/>
	                <input type="submit" value="추가">
                        </form>
                    </li>
                </ul>
            </div>
            <div style="text-align: center;">
            	<button class="nav-link" onclick="location.href='checking.jsp'">메뉴로 돌아가기</button>
            </div>
        </div>
    </section>
</body>
</html>
