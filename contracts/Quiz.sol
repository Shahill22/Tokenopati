// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./AccuCoin.sol";

contract Quiz is Ownable {
    AccuCoin public token;
    address public treasury;
    mapping(address => uint) public tokens;
    mapping(address => uint) public tokensInvested;
    mapping(address => bool) public quizAnswered;

    event TokenTransfer(address from, address to, uint tokens);

    constructor(address _tokenAddress, address _treasury) Ownable() {
        require(_tokenAddress != address(0), "Quiz: Invalid token address");
        token = new AccuCoin(100000000 * 1e18);
        treasury = _treasury;
    }

    function initailTokensToParticipate(
        address _player,
        uint256 _amount
    ) external payable onlyOwner {
        require(_amount >= 1, "Quiz: Insufficient payment");
        require(_player != address(0), "Quiz: Invalid address");

        token.transfer(_player, _amount);
        tokens[_player] += _amount;
        emit TokenTransfer(msg.sender, _player, _amount);
    }

    function participateInQuiz(uint256 _investAmount) public payable {
        require(_investAmount >= 1, "Quiz: Insufficient payment");
        token.transferFrom(msg.sender, treasury, _investAmount);
        tokens[msg.sender] -= _investAmount;
        tokensInvested[msg.sender] += _investAmount;
        emit TokenTransfer(msg.sender, treasury, _investAmount);
    }

    function answerQuiz(bool answer, uint256 _rewardMultiplier) public {
        require(tokensInvested[msg.sender] >= 1, "Quiz: No tokens Invested");
        require(!quizAnswered[msg.sender], "Quiz already answered");

        if (answer == true) {
            uint256 tokensReward = tokensInvested[msg.sender] *
                _rewardMultiplier;
            token.transferFrom(treasury, msg.sender, tokensReward);
            tokens[msg.sender] += tokensReward;
            emit TokenTransfer(treasury, msg.sender, tokensReward);
        }
        quizAnswered[msg.sender] = true;
    }

    function checkAnswer() public view returns (bool) {
        return quizAnswered[msg.sender];
    }

    function checkTokens() public view returns (uint) {
        return tokens[msg.sender];
    }
}
