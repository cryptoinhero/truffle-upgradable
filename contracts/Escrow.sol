pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

import '@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol';
import '@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol';
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract Escrow is OwnableUpgradeable {
    using SafeMath for uint256;

    address public wallet;
    IBEP20 public token;

    uint256 public depositFee;
    uint256 public withdrawFee;
    
    mapping(address => uint256) public balances; // token balances

    event Deposited(address indexed payee, uint256 tokenAmount);
    event Withdrawn(address indexed payee, uint256 tokenAmount);
    
    function initialize(IBEP20 _token, address _wallet, uint256 _depositFee, uint256 _withdrawFee) public initializer {
        __Ownable_init();

        token = _token;
        wallet = _wallet;
        depositFee = _depositFee;
        withdrawFee = _withdrawFee;
    }
    function _authorizeUpgrade(address newImplementation) internal {}
    
    function deposit(uint256 _amount) public {
        require(_amount > 0, "Invalid amount");
        require(token.transferFrom(msg.sender, address(this), _amount));

        if(depositFee > 0) {
            uint256 fee = _amount.mul(depositFee).div(10000);
            token.transfer(wallet, fee);
            _amount = _amount.sub(fee);
        }

        balances[msg.sender] = balances[msg.sender].add(_amount);
        
        emit Deposited(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount && _amount > 0);
        
        if(depositFee > 0) {
            uint256 fee = _amount.mul(withdrawFee).div(10000);
            _amount = _amount.sub(fee);

            token.transfer(wallet, fee);
            balances[msg.sender] = balances[msg.sender].sub(fee);
        }

        token.transfer(msg.sender, _amount);
        balances[msg.sender] = balances[msg.sender].sub(_amount);

        emit Withdrawn(msg.sender, _amount);
    }

    function setFee(uint256 _depositFee, uint256 _withdrawFee) external onlyOwner {
        require(_depositFee >= 0 && _withdrawFee >= 0, "Invalid fee");
        
        depositFee = _depositFee;
        withdrawFee = _withdrawFee;
    }

    function setWallet(address _wallet) public {
        require(wallet == msg.sender, "setWallet: Forbidden");
        wallet = _wallet;
    }
}