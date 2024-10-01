let quantity = 1;

const quantityDisplay = document.getElementById('quantity');
const decreaseButton = document.getElementById('decrease');
const increaseButton = document.getElementById('increase');

decreaseButton.addEventListener('click', () => {
    if (quantity > 1) { // 최소 수량을 1로 설정
        quantity--;
        quantityDisplay.textContent = quantity;
    }
});

increaseButton.addEventListener('click', () => {
    quantity++;
    quantityDisplay.textContent = quantity;
});
