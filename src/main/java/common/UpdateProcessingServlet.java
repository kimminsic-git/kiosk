package common;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import DBPKG.JDBConnect;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet("/manage/updateProcessing")
@MultipartConfig
public class UpdateProcessingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter();
             Connection conn = new JDBConnect().getConnection()) {
             
            // 파일 업로드 경로 설정
        	String uploadPath = request.getServletContext().getRealPath("/image");
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists() && !uploadDir.mkdirs()) {
                out.println("<script>alert('업로드 디렉토리 생성 실패');</script>");
                return;
            }

            // 파일명 및 경로 설정
            String cofname = request.getParameter("cofname");
            String customFileName = cofname + ".jpg";
            String filePath = uploadPath + File.separator + customFileName;

            // 파일 저장
            Part filePart = request.getPart("productImage");
            if (filePart != null && filePart.getSize() > 0) {
                try (InputStream fileContent = filePart.getInputStream();
                     FileOutputStream fos = new FileOutputStream(filePath)) {
                    byte[] buffer = new byte[1024];
                    int bytesRead;
                    while ((bytesRead = fileContent.read(buffer)) != -1) {
                        fos.write(buffer, 0, bytesRead);
                    }
                }
            }

            // 첫 번째 INSERT 쿼리
            String sql = "INSERT INTO Menu_2024_10 (cofnum, cofname, price, catego, tem, cofsell) VALUES (?, ?, ?, ?, ?, 0)";
            try (PreparedStatement psmt = conn.prepareStatement(sql)) {
                psmt.setString(1, request.getParameter("cofid"));
                psmt.setString(2, cofname);
                psmt.setString(3, request.getParameter("price"));
                psmt.setString(4, request.getParameter("catego"));
                psmt.setString(5, request.getParameter("tem"));
                int rowsAffected1 = psmt.executeUpdate();

                // 두 번째 INSERT 쿼리
                String sql1 = "INSERT INTO remain_2024_10 VALUES (?, ?, ?, ?, ?)";
                try (PreparedStatement psmt1 = conn.prepareStatement(sql1)) {
                    psmt1.setString(1, request.getParameter("cofid"));
                    psmt1.setString(2, cofname);
                    psmt1.setString(3, request.getParameter("price"));
                    psmt1.setString(4, request.getParameter("sellable"));
                    psmt1.setString(5, request.getParameter("remaincount"));
                    int rowsAffected2 = psmt1.executeUpdate();

                    // 결과 출력
                    if (rowsAffected1 > 0 && rowsAffected2 > 0) {
                        out.println("<script>alert('업데이트 성공!'); window.location.href='checking.jsp';</script>");
                    } else {
                        out.println("<script>alert('업데이트 실패!'); window.location.href='checking.jsp';</script>");
                    }
                }
            }
        } catch (SQLException e) {
            response.getWriter().println("<script>alert('DB 오류 발생: " + e.getMessage() + "');</script>");
        } catch (Exception e) {
            response.getWriter().println("<script>alert('오류 발생: " + e.getMessage() + "');</script>");
        }
    }
}
