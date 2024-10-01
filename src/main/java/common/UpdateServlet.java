package common;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import DBPKG.JDBConnect;

@WebServlet("/manage/updateServlet")
@MultipartConfig
public class UpdateServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	    request.setCharacterEncoding("UTF-8");
	    response.setContentType("text/html; charset=UTF-8");
	    response.setCharacterEncoding("UTF-8");

	    JDBConnect db = new JDBConnect();
	    Connection conn = null;
	    PreparedStatement psmt = null;
	    PreparedStatement psmt1 = null;

	    String cofids = request.getParameter("cofid");
	    String cofname = request.getParameter("cofname");
	    String oldCofname = request.getParameter("oldCofname");
	    String price = request.getParameter("price");
	    String catego = request.getParameter("catego");
	    String tem = request.getParameter("tem");
	    String sellingcount = request.getParameter("sellingcount"); 
	    String sellable = request.getParameter("sellable");
	    String remaincount = request.getParameter("remaincount");
	    Part filePart = request.getPart("productImage"); // 업로드된 파일 가져오기

	    String newFileName = cofname + ".jpg"; // 새로운 파일 이름
	    String oldFileName = oldCofname + ".jpg"; // 기존 파일 이름
	    String imagePath = getServletContext().getRealPath("/image/"); // 저장 경로

	    try {
	        conn = db.getConnection();

	        // 첫 번째 업데이트 쿼리
	        String sql = "UPDATE remain_2024_10 SET cofname = ?, price = ?, sellable = ?, remaincount = ? WHERE cofid = ?";
	        psmt = conn.prepareStatement(sql);
	        psmt.setString(1, cofname);
	        psmt.setString(2, price);
	        psmt.setString(3, sellable);
	        psmt.setString(4, remaincount);
	        psmt.setString(5, cofids);
	        int rowsAffected1 = psmt.executeUpdate();

	        // 두 번째 업데이트 쿼리
	        String sql1 = "UPDATE Menu_2024_10 SET cofname = ?, price = ?, tem = ?, catego = ?, cofsell = ? WHERE cofnum = ?";
	        psmt1 = conn.prepareStatement(sql1);
	        psmt1.setString(1, cofname);
	        psmt1.setString(2, price);
	        psmt1.setString(3, tem);
	        psmt1.setString(4, catego);
	        psmt1.setString(5, sellingcount);
	        psmt1.setString(6, cofids);
	        int rowsAffected2 = psmt1.executeUpdate();

	        // 결과 출력
	        if (rowsAffected1 > 0 && rowsAffected2 > 0) {
	            response.getWriter().println("<script>alert('업데이트 성공!')</script>");

	            // 파일이 업로드된 경우에만 파일 저장 로직 실행
	            if (filePart != null && filePart.getSize() > 0) {
	                File fileToSave = new File(imagePath + newFileName);
	                try {
	                    filePart.write(fileToSave.getAbsolutePath()); // 새로운 파일 저장
	                } catch (IOException e) {
	                    response.getWriter().println("<script>alert('파일 저장 중 오류 발생!')</script>");
	                }
	            } else {
	                // 이미지가 업로드되지 않았을 경우, 기존 파일 이름을 새로운 파일 이름으로 변경
	                File oldFile = new File(imagePath + oldFileName);
	                File newFile = new File(imagePath + newFileName);
	                if (oldFile.exists()) {
	                    // 기존 파일의 이름을 새로운 파일 이름으로 변경
	                    oldFile.renameTo(newFile);
	                }
	            }
	        } else {
	            response.getWriter().println("<script>alert('업데이트 실패!')</script>");
	        }

	    } catch (SQLException e) {
	        response.getWriter().println("<script>alert('" + e.getMessage() + "')</script>");
	    } finally {
	        if (psmt != null) try { psmt.close(); } catch (SQLException ignore) {}
	        if (psmt1 != null) try { psmt1.close(); } catch (SQLException ignore) {}
	        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
	    }

	    // 0.5초 후 리다이렉트
	    response.setHeader("Refresh", "0.5; URL=checking.jsp");
	}
}