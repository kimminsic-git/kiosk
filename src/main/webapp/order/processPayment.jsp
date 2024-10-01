<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.*" %>
<%@page import="java.sql.*" %>
<%@page import="DBPKG.JDBConnect" %>

<%
Map<String, Integer> selectedCofnums = (Map<String, Integer>) session.getAttribute("selectedCofnums");
if (selectedCofnums == null) {
    selectedCofnums = new HashMap<>();
}

JDBConnect db = new JDBConnect();
Connection conn = null;
PreparedStatement psmt = null;
ResultSet rs = null;
int allprice = 0;

try {
    conn = db.getConnection();
    out.println("<ul class='payment-list'>");
    for (Map.Entry<String, Integer> entry : selectedCofnums.entrySet()) {
        String cofnum = entry.getKey().replaceAll("[^0-9]", "");
        int quantity = entry.getValue();

        String sql = "SELECT * FROM MENU_2024_10 WHERE cofnum = ?";
        psmt = conn.prepareStatement(sql);
        psmt.setString(1, cofnum);
        rs = psmt.executeQuery();

        while (rs.next()) {
            String menuName = rs.getString("cofname");
            int price = rs.getInt("price");

            out.println("<li class='order-item' data-cofnum='" + cofnum + "'>");
            out.println("<span class='item-name'><b>" + menuName + "</b></span>");
            out.println("<span class='item-quantity'>" + quantity + "개</span>");
            out.println("<span>가격: <span class='total-price'>" + price * quantity + "</span> 원</span>");
            out.println("</li>");
            allprice += price * quantity;
        }
    }
    out.println("<li>합계: " + allprice + "원</li>");
    out.println("</ul>");
    out.println("<button class='purchasereal'>결제하기</button>");
} catch (SQLException e) {
    e.printStackTrace();
    out.println("<h2>데이터베이스 오류가 발생했습니다.</h2>");
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
    if (psmt != null) try { psmt.close(); } catch (SQLException ignore) {}
    if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
}
%>

<!-- 모달 구조 -->
<div id="paymentModal2" class="modal" style="display: none;">
    <div class="modal-content">
        <span class="close-button" onclick="closeModal2()">&times;</span>
        	<div>
        		<button class="sele" style="background-color:red;" onclick="sendOrder('포장')">포장</button>
				<button class="sele" style="background-color:blue" onclick="sendOrder('매장')">매장</button>
        	</div>
    </div>
</div>

<!-- CSS 스타일 -->
<style>
.modal {
    display: none; /* 기본적으로 숨김 */
    position: fixed;
    z-index: 1;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    overflow: auto;
    background-color: rgba(0, 0, 0, 0.5); /* 반투명 배경 */
}

.modal-content {
    background-color: #fefefe;
    margin: 15% auto;
    padding: 20px;
    border: 1px solid #888;
    width: 80%; /* 모달 너비 */
}

.close-button {
    color: #aaa;
    float: right;
    font-size: 28px;
    font-weight: bold;
}

.close-button:hover,
.close-button:focus {
    color: black;
    text-decoration: none;
    cursor: pointer;
}
</style>

<!-- JavaScript -->
<script>
document.querySelector('.purchasereal').addEventListener('click', openModal2);
document.querySelector('.close-button').addEventListener('click', closeModal2);

function openModal2() {
    document.getElementById("paymentModal2").style.display = "block";
}

function closeModal2() {
    document.getElementById("paymentModal2").style.display = "none";
}
function sendOrder(type) {
    const orderDetails = [];

    // 주문 목록에서 각 항목의 정보를 수집
    $('.payment-list li').each(function() {
        const menuName = $(this).find('.item-name b').text();
        const quantityText = $(this).find('.item-quantity').text();
        const quantity = quantityText.replace(/개/, '').trim();
        const totalPrice = $(this).find('.total-price').text().trim();
        const cofnum = $(this).data('cofnum');

        // 빈 값 체크
        if (menuName && quantity && totalPrice && cofnum) {
            orderDetails.push({
                cofnum: cofnum,
                menuName: menuName,
                quantity: quantity,
                totalPrice: totalPrice
            });
        }
    });

    // orderDetails가 비어 있지 않은지 확인
    if (orderDetails.length > 0) {
        const orderData = JSON.stringify(orderDetails);

        // AJAX 요청으로 데이터 전송
        $.ajax({
            url: 'processOrder.jsp',
            type: 'POST',
            data: {
                orderData: orderData,
                orderType: type
            },
            success: function(response) {
                closeModal2(); // 모달 닫기

                // 주문 정보를 URL 매개변수로 넘겨서 페이지 이동
                window.location.href = 'insertorder.jsp?orderData=' + encodeURIComponent(orderData) + '&orderType=' + encodeURIComponent(type);
            },
            error: function() {
                alert('주문 처리 중 오류가 발생했습니다.');
            }
        });
    } else {
        alert('주문할 항목이 없습니다.');
    }
}


</script>
