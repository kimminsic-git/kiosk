<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="java.sql.*"%>
<%@page import="DBPKG.JDBConnect"%>
<%@page import="java.util.HashMap"%>
<%
Map<String, Integer> selectedCofnums = (Map<String, Integer>) session.getAttribute("selectedCofnums");
if (selectedCofnums == null) {
    selectedCofnums = new HashMap<>();
}

// 세션 초기화
if (session.getAttribute("selectedCofnums") == null) {
    session.setMaxInactiveInterval(10 * 60); // 10분
    session.setAttribute("selectedCofnums", new HashMap<String, Integer>());
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>주문 목록</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<div id="order-details">
    <%
    if (selectedCofnums.isEmpty()) {
        out.println("<h2>주문이 없습니다.</h2>");
    } else {
        JDBConnect db = new JDBConnect();
        Connection conn = null;
        PreparedStatement psmt = null;
        ResultSet rs = null;

        try {
            conn = db.getConnection();
            out.println("<ul class='order-list'>");
            for (Map.Entry<String, Integer> entry : selectedCofnums.entrySet()) {
                String cofnums = entry.getKey();
                int quantity = entry.getValue();
                String cofnum = cofnums.replaceAll("[^0-9]", "");

                String sql = "SELECT * FROM MENU_2024_10 WHERE cofnum = ?";
                psmt = conn.prepareStatement(sql);
                psmt.setString(1, cofnum);
                rs = psmt.executeQuery();

                while (rs.next()) {
                    String menuName = rs.getString("cofname");
                    int price = rs.getInt("price");
                    String temp = rs.getString("tem");

                    if (temp.equals("Hot/Ice")) {
                        temp = "";
                    }

                    out.println("<li class='order-item' data-cofnum='" + cofnum + "'>");
                    out.println("<span class='item-name'><b>" + menuName + "</b></span>");
                    out.println("<span class='item-temp'>" + temp + "</span>");
                    out.println("<span class='item-price'>가격: <span class='price'>" + price + "</span> 원</span>");
                    out.println("<span class='item-quantity'>");
                    out.println("<button class='updown' onclick='changeQuantity(this, -1, " + price + ")'>-</button>");
                    out.println("<span class='quantity'>" + quantity + "</span>");
                    out.println("<button class='updown' onclick='changeQuantity(this, 1, " + price + ")'>+</button>");
                    out.println("</span>");
                    out.println("<span>총 가격:</span>");
                    out.println("<span class='total-price'>" + (price * quantity) + " 원</span>");
                    out.println("<button class='remove' onclick='removeItem(\"" + cofnum + "\")'></button>");
                    out.println("</li>");
                }
            }
            out.println("</ul>");
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<h2>데이터베이스 오류가 발생했습니다.</h2>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
            if (psmt != null) try { psmt.close(); } catch (SQLException ignore) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
        }
    }
    %>

    <script>
        selectedCofnums = <%
            StringBuilder jsonBuilder = new StringBuilder("{");
            for (Map.Entry<String, Integer> entry : selectedCofnums.entrySet()) {
                jsonBuilder.append("\"").append(entry.getKey()).append("\":").append(entry.getValue()).append(",");
            }
            if (jsonBuilder.length() > 1) jsonBuilder.setLength(jsonBuilder.length() - 1);
            jsonBuilder.append("}");
            out.print(jsonBuilder.toString());
        %>;

        $(document).ready(function() {
            calculateTotalAmount();
            $('#paymentButton').on('click', function() {
            	if ($('li.order-item').length === 0){
            		alert("주문이 없습니다.")
            		return;
            	} 
                openPaymentModal();
            });
        });

        function calculateTotalAmount() {
            let totalAmount = 0;
            $('.total-price').each(function() {
                const priceText = $(this).text().replace(' 원', '');
                const priceValue = parseInt(priceText, 10) || 0;
                totalAmount += priceValue;
            });
            $('.allprice').text(totalAmount);
        }

        function removeItem(cofnum) {
            if (!confirm('이 항목을 정말 삭제하시겠습니까?')) {
                return;
            }

            selectedCofnums[cofnum] = 0;

            $.ajax({
                url: 'saveOrder.jsp',
                type: 'POST',
                data: {
                    cofnums: JSON.stringify(selectedCofnums)
                },
                success: function(response) {
                    loadOrderDetails();
                    $(`.order-item[data-cofnum='${cofnum}']`).remove();
                },
                error: function() {
                    alert('주문 삭제 중 오류가 발생했습니다.');
                }
            });
        }

        function changeQuantity(button, change, price) {
            const itemDiv = button.closest('.order-item');
            const quantitySpan = itemDiv.querySelector('.quantity');
            let quantity = parseInt(quantitySpan.innerText);
            quantity += change;

            if (quantity < 0) quantity = 0;

            quantitySpan.innerText = quantity;

            const totalPriceSpan = itemDiv.querySelector('.total-price');
            totalPriceSpan.innerText = (price * quantity) + " 원";

            const cofnum = itemDiv.getAttribute('data-cofnum');
            selectedCofnums[cofnum] = quantity;

            $.ajax({
                url: 'saveOrder.jsp',
                type: 'POST',
                data: {
                    cofnums: JSON.stringify(selectedCofnums)
                },
                success: function() {
                    if (quantity === 0) {
                        removeItem(cofnum);
                    }
                },
                error: function() {
                    alert('수량 업데이트 중 오류가 발생했습니다.');
                }
            });
        }

        function openPaymentModal() {
            const orderDetails = [];
            
            $('.order-item').each(function() {
                const menuName = $(this).find('.item-name b').text();
                const quantity = $(this).find('.quantity').text();
                const totalPrice = $(this).find('.total-price').text().trim();
                
                orderDetails.push({
                    menuName: menuName,
                    quantity: quantity,
                    totalPrice: totalPrice
                });
            });

            const orderData = JSON.stringify(orderDetails);

            $.ajax({
                url: 'processPayment.jsp',
                type: 'POST',
                data: {
                    orderData: orderData
                },
                success: function(response) {
                    $('#modal-contents').html(response);
                    $('#paymentModal1').show();
                },
                error: function() {
                    alert('결제 정보를 전송하는 중 오류가 발생했습니다.');
                }
            });
        }

        function closeModal1() {
            $('#paymentModal1').hide();
        }

        function confirmPayment() {
            alert("결제가 완료되었습니다.");
            closeModal1();
        }
    </script>
</div>

<div class="buttom">
    <span class="pri">총금액: <span class="allprice"></span> 원</span>
    <button class="purchase" id="paymentButton">결제하기</button>
</div>

<div id="paymentModal1" class="modal" style="display: none;">
    <div class="modal-content">
        <button class="close" onclick="closeModal1()">&times;</button>
        <h2>결제하기</h2>
        <div id="modal-contents"></div>
    </div>
</div>

</body>
</html>
