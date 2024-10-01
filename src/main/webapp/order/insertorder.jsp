<%@page language="java" contentType="text/html; charset=UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="java.sql.*"%>
<%@page import="DBPKG.JDBConnect"%>

<%
String orderData = request.getParameter("orderData");
String orderType = request.getParameter("orderType");

if (orderType == null || orderData == null) {
    out.println("<script>alert('주문 데이터가 없습니다.'); window.history.back();</script>");
    return;
}

if (orderType.equals("포장")) {
    orderType = "pack";
} else if (orderType.equals("매장")) {
    orderType = "mall"; 
} else {
    out.println("<script>alert('잘못된 주문 유형입니다.'); window.history.back();</script>");
    return;
}

JDBConnect db = new JDBConnect();
try (Connection conn = db.getConnection()) {
    orderData = orderData.replace("[", "").replace("]", "");
    String[] orderItems = orderData.split("\\},\\{");
    List<String> insufficientItems = new ArrayList<>(); // 부족한 품목을 저장할 리스트
    boolean isStockAvailable = true;

    // 재고 체크
    for (String item : orderItems) {
        item = item.replace("{", "").replace("}", "").trim();
        String[] details = item.split(",");
        String cofnum = "";
        int quantity = 0;

        for (String detail : details) {
            String[] parts = detail.split(":");
            if (parts.length == 2) {
                String key = parts[0].replace("\"", "").trim();
                String value = parts[1].replace("\"", "").trim();
                if (key.equals("cofnum")) {
                    cofnum = value;
                } else if (key.equals("quantity")) {
                    quantity = Integer.parseInt(value);
                }
            }
        }

        // remaincount 확인
        String stockCheckSql = "SELECT remaincount, cofname FROM remain_2024_10 WHERE cofid = ?";
        try (PreparedStatement stockCheckStmt = conn.prepareStatement(stockCheckSql)) {
            stockCheckStmt.setInt(1, Integer.parseInt(cofnum));
            ResultSet stockRs = stockCheckStmt.executeQuery();
            if (stockRs.next()) {
                int remainCount = stockRs.getInt("remaincount");
                String cofname = stockRs.getString("cofname"); // cofname을 저장

                if (remainCount < quantity) {
                    insufficientItems.add(cofname); // 부족한 품목 추가
                    isStockAvailable = false;
                }
            }
        }
    }

    if (!isStockAvailable) {
        StringBuilder alertMessage = new StringBuilder();
        for (String item : insufficientItems) {
        	alertMessage.append("(");
            alertMessage.append(item).append("), ");
        }
        alertMessage.setLength(alertMessage.length() - 2); // 마지막 ", " 제거
        out.println("<script>alert('" + alertMessage.toString() + "의 재고가 부족합니다.'); window.history.back();</script>");
        return;
    }

    // 주문 ID 생성
    String orderIdSql = "SELECT NVL(MAX(orderid), 0) + 1 AS next_orderid FROM Order_2024_10";
    int currentOrderId = 0;

    try (PreparedStatement psmt = conn.prepareStatement(orderIdSql);
         ResultSet rs = psmt.executeQuery()) {
        if (rs.next()) {
            currentOrderId = rs.getInt("next_orderid");
        }
    }

    // 주문 정보 INSERT
    String insertOrderSql = "INSERT INTO Order_2024_10 (orderid, orderdat, totalprice, packing) VALUES (?, SYSDATE, 0, ?)";
    try (PreparedStatement insertOrderStmt = conn.prepareStatement(insertOrderSql)) {
        insertOrderStmt.setInt(1, currentOrderId);
        insertOrderStmt.setString(2, orderType);
        insertOrderStmt.executeUpdate();
    }

    // 주문 상세 저장
    for (String item : orderItems) {
        item = item.replace("{", "").replace("}", "").trim();
        String[] details = item.split(",");
        String cofnum = "";
        int quantity = 0;

        for (String detail : details) {
            String[] parts = detail.split(":");
            if (parts.length == 2) {
                String key = parts[0].replace("\"", "").trim();
                String value = parts[1].replace("\"", "").trim();
                if (key.equals("cofnum")) {
                    cofnum = value;
                } else if (key.equals("quantity")) {
                    quantity = Integer.parseInt(value);
                }
            }
        }
        
        // 상세 ID 생성
        String detailIdSql = "SELECT NVL(MAX(ordeid), 0) + 1 AS next_detailid FROM orderde_2024_10";
        int currentDetailId = 0;
        try (PreparedStatement detailIdStmt = conn.prepareStatement(detailIdSql);
             ResultSet detailRs = detailIdStmt.executeQuery()) {
            if (detailRs.next()) {
                currentDetailId = detailRs.getInt("next_detailid");
            }
        }

        if (!cofnum.isEmpty() && quantity > 0) {
            String insertDetailSql = "INSERT INTO orderde_2024_10 (ordeid, orderid, cofnum, count) VALUES (?, ?, ?, ?)";
            try (PreparedStatement insertDetailStmt = conn.prepareStatement(insertDetailSql)) {
                insertDetailStmt.setInt(1, currentDetailId);
                insertDetailStmt.setInt(2, currentOrderId);
                insertDetailStmt.setInt(3, Integer.parseInt(cofnum));
                insertDetailStmt.setInt(4, quantity);
                insertDetailStmt.executeUpdate();
            }
        }
    }

    // 총합계 업데이트 쿼리
    String updateTotalPriceSql = "UPDATE Order_2024_10 SET totalprice = (" +
        "SELECT SUM(m.price * od.count) " +
        "FROM orderde_2024_10 od " +
        "JOIN Menu_2024_10 m ON od.cofnum = m.cofnum " +
        "WHERE od.orderid = Order_2024_10.orderid " +
        ") WHERE orderid = (SELECT MAX(orderid) FROM Order_2024_10)";

    try (PreparedStatement updateTotalPriceStmt = conn.prepareStatement(updateTotalPriceSql)) {
        updateTotalPriceStmt.executeUpdate();
    }

    // cofsell 업데이트 쿼리
    String updateCofSellSql = "UPDATE Menu_2024_10 m SET cofsell = cofsell + (" +
        "SELECT SUM(od.count) " +
        "FROM orderde_2024_10 od " +
        "WHERE od.cofnum = m.cofnum " +
        "AND od.orderid = (SELECT MAX(orderid) FROM Order_2024_10)" +
        ") WHERE cofnum IN (" +
        "SELECT DISTINCT cofnum " +
        "FROM orderde_2024_10 " +
        "WHERE orderid = (SELECT MAX(orderid) FROM Order_2024_10)" +
        ")";

    try (PreparedStatement updateCofSellStmt = conn.prepareStatement(updateCofSellSql)) {
        updateCofSellStmt.executeUpdate();
    }

    // remaincount 업데이트
    String updateRemainCountSql = "UPDATE remain_2024_10 r SET remaincount = remaincount - (" +
        "SELECT SUM(od.count) " +
        "FROM orderde_2024_10 od " +
        "WHERE od.cofnum = r.cofid " +
        "AND od.orderid = (SELECT MAX(orderid) FROM Order_2024_10)" +
        ") WHERE r.cofid IN (" +
        "SELECT DISTINCT cofnum " +
        "FROM orderde_2024_10 " +
        "WHERE orderid = (SELECT MAX(orderid) FROM Order_2024_10)" +
        ")";

    try (PreparedStatement updateRemainCountStmt = conn.prepareStatement(updateRemainCountSql)) {
        updateRemainCountStmt.executeUpdate();
    }

    // 성공 메시지 및 페이지 리다이렉션
    out.println("<script>alert('주문이 성공적으로 저장되었습니다!'); window.location.href='/kiosk/index.jsp';</script>");
} catch (SQLException e) {
    out.println("<script>alert('주문 저장 중 오류가 발생했습니다.'); window.history.back();</script>");
}
%>
