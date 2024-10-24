// Используем глобальный Web3
const web3 = new Web3(window.ethereum || "http://localhost:8545");

// Интерфейс контракта
const contractABI = [
  {
    "constant": true,
    "inputs": [],
    "name": "getMessage",
    "outputs": [{"name": "", "type": "string"}],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  }
];

// Адрес развернутого смарт-контракта
const contractAddress = '0xB3ECC1782cdf11153355A7954556364eA07ABf99';  // Замените на фактический адрес контракта

// Получаем контрактную инстанцию
const contract = new web3.eth.Contract(contractABI, contractAddress);

// Получение кнопки с страницы
window.onload = function() {
  const button = document.getElementById('helloButton');
  
  if (button) {
    // Добавление обработчика клика
    button.addEventListener('click', async () => {
      try {
        // Взаимодействие со смарт-контрактом
        const message = await contract.methods.getMessage().call();
        alert(message);  // Появляется окно с текстом из контракта "Привет, Мир!"
      } catch (error) {
        console.error("Ошибка взаимодействия с контрактом:", error);
      }
    });
  }
};
