// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./AccuCoin.sol";

contract Quiz is Ownable {
    AccuCoin public token;
    address public treasury;
    //uint256 public questionID;
    struct ClaimState {
        uint256 initiateTime;
        uint256 initiateCount;
    }
    struct QuestionState {
        uint256 questionID;
        bool visible;
    }
    uint256 public maturityPeriod = 4; //4hrs
    mapping(address => ClaimState) private UserClaimStates;
    mapping(address => QuestionState) private QuestionToUser;
    mapping(address => uint) public UserTokensBalance;
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
        ClaimState storage claimState = UserClaimStates[_player];

        require(_amount >= 1, "Quiz: Insufficient payment");
        require(_player != address(0), "Quiz: Invalid address");
        if (claimState.initiateCount == 0) {
            claimState.initiateTime = block.timestamp;
            claimState.initiateCount += 1;
            token.transfer(_player, _amount);
            UserTokensBalance[_player] += _amount;
        } else {
            require(
                ((block.timestamp - claimState.initiateTime) / 1 hours) >=
                    maturityPeriod,
                "Quiz: required time not elapsed"
            );
            claimState.initiateTime = block.timestamp;
            claimState.initiateCount += 1;

            token.transfer(_player, _amount);
            UserTokensBalance[_player] += _amount;
        }

        emit TokenTransfer(msg.sender, _player, _amount);
    }

    function participateInQuiz(
        uint256 _investAmount,
        uint256 _questionID
    ) public payable {
        QuestionState storage questionState = QuestionToUser[msg.sender];
        require(_investAmount >= 1, "Quiz: Insufficient payment");
        require(
            questionState.visible == false,
            "Quiz: question already attended"
        );

        token.transferFrom(msg.sender, treasury, _investAmount);
        UserTokensBalance[msg.sender] -= _investAmount;
        tokensInvested[msg.sender] += _investAmount;
        questionState.questionID = _questionID;
        questionState.visible = true;
        emit TokenTransfer(msg.sender, treasury, _investAmount);
    }

    function answerQuiz(bool answer, uint256 _rewardMultiplier) public {
        require(tokensInvested[msg.sender] >= 1, "Quiz: No tokens Invested");
        require(!quizAnswered[msg.sender], "Quiz already answered");

        if (answer == true) {
            uint256 tokensReward = tokensInvested[msg.sender] *
                _rewardMultiplier;
            token.transferFrom(treasury, msg.sender, tokensReward);
            UserTokensBalance[msg.sender] += tokensReward;
            emit TokenTransfer(treasury, msg.sender, tokensReward);
        }
        quizAnswered[msg.sender] = true;
    }

    function checkAnswer() public view returns (bool) {
        return quizAnswered[msg.sender];
    }

    function checkTokens() public view returns (uint) {
        return UserTokensBalance[msg.sender];
    }
}
