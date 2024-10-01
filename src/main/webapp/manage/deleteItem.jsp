<%@page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="DBPKG.JDBConnect"%>
<%@page import="java.io.File"%>
<%
    String cofid = request.getParameter("cofid"); // 요청에서 cofid 가져오기
    String cofname = request.getParameter("cofname"); // 요청에서 cofname 가져오기

    JDBConnect db = new JDBConnect();
    Connection conn = null;
    PreparedStatement psmt = null;
    PreparedStatement psmt1 = null;
    ResultSet rs = null;

    response.setContentType("text/html;charset=UTF-8");
    response.setCharacterEncoding("UTF-8");

    String imagePath = application.getRealPath("/image/" + cofname + ".jpg"); // 이미지 경로 설정

    try {
        conn = db.getConnection();

        // 첫 번째 DELETE 쿼리
        String sql = "DELETE FROM remain_2024_10 WHERE cofid = ?";
        psmt = conn.prepareStatement(sql);
        psmt.setString(1, cofid);
        psmt.executeUpdate();

        // 두 번째 DELETE 쿼리
        String sql1 = "DELETE FROM Menu_2024_10 WHERE cofnum = ?";
        psmt1 = conn.prepareStatement(sql1);
        psmt1.setString(1, cofid);
        psmt1.executeUpdate();

        // 이미지 파일 삭제
        if (!imagePath.isEmpty()) {
            File imageFile = new File(imagePath);
            if (imageFile.exists()) {
                imageFile.delete(); // 파일 삭제
            }
        }

        // 성공 메시지
        out.println("<script>alert('삭제 성공!'); window.location.href='checking.jsp';</script>");
    } catch (Exception e) {
        e.printStackTrace();
        // HTML 인코딩 처리
        String errorMessage = e.getMessage() != null ? e.getMessage().replace("'", "\\'").replace("<", "&lt;").replace(">", "&gt;") : "알 수 없는 오류가 발생했습니다.";
        out.println("<script>alert('오류 발생: " + errorMessage + "'); window.location.href='checking.jsp';</script>");
    } finally {
        // 자원 해제
        if (rs != null) try { rs.close(); } catch (Exception ignore) {}
        if (psmt != null) try { psmt.close(); } catch (Exception ignore) {}
        if (psmt1 != null) try { psmt1.close(); } catch (Exception ignore) {}
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }
%>
