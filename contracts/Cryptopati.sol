// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IAccuCoin.sol";

contract Cryptopati is Ownable, Pausable {
    IAccuCoin public accuCoin; // Address of the Accu Coin
    address public platform; // Platform wallet manages certain functions
    uint256 public initialAmount = 100; // Amount that can be claimed initially
    bool public isInitialClaimable = true; // Boolean indicating whether the initial claiming for tokens is open
    uint256 public replenishAmount = 10; // Amount that can be claimed when replenished
    uint256 public replenishDuration = 1 hours; // Duration after which tokens will be replenished
    bool public isReplenishable = true; // Boolean indicating whether the claiming for tokens is replenishable
    uint256 private multiplierAmount; //multiplier amount of the users invested token to a question

    struct Question {
        uint256 multiplier;
        bool exist;
    }
    mapping(string => Question) private _questions; // Question ID => Question {}

    struct UserToQuestionId {
        bool answered;
        uint256 unlockTimestamp;
        uint256 commitAmount;
        uint256 collectedAmount;
    }
    mapping(address => mapping(string => UserToQuestionId))
        public userToQuestionId;

    struct User {
        uint256 totalCommitAmount;
        uint256 totalAmountCollected;
    }
    mapping(address => User) public userInfo;

    mapping(address => uint256) public userLastClaim; // Timestamp at which user claimed token last

    /* Events */
    event QuestionAdd(string questionId);
    event ClaimTokens(address indexed user, uint256 amount);
    event UnlockQuestion(
        address indexed user,
        string questionId,
        uint256 commitAmount
    );
    event WinQuestion(
        address indexed user,
        string questionId,
        uint256 rewardAmount
    );

    /* Modifiers */
    modifier onlyValid(string calldata questionId) {
        require(questionExist(questionId), "Cryptopati: invalid question");
        _;
    }

    constructor(IAccuCoin _accuCoin, address _platform) Ownable() {
        accuCoin = _accuCoin;
        platform = _platform;
    }

    /**
     * @notice This method is used pause user functionalities of the contract
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice This method is used unpause user functionalities of the contract
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice This method is used to address of accu coin
     * @param _accuCoin Address of accu coin
     */
    function setAccuCoin(IAccuCoin _accuCoin) external onlyOwner {
        accuCoin = _accuCoin;
    }

    /**
     * @notice This method is used to set platform wallet address
     * @param _platform Address of the platform wallet
     */
    function setPlatform(address _platform) external onlyOwner {
        platform = _platform;
    }

    /**
     * @notice This method is used to toggle initial token claim
     */
    function toggleIsInitialClaimable() external onlyOwner {
        isInitialClaimable = !isInitialClaimable;
    }

    /**
     * @notice This method is used to toggle token replenish claim
     */
    function toggleIsReplenishable() external onlyOwner {
        isReplenishable = !isReplenishable;
    }

    /**
     * @notice This method is used to set token claim settings
     * @param _initialAmount Initial amount that can be claimed by an address
     * @param _replenishAmount Amount of tokens that can be claimed when replenished
     * @param _replenishDuration Duration in which token will replenish
     */
    function configureClaim(
        uint256 _initialAmount,
        uint256 _replenishAmount,
        uint256 _replenishDuration
    ) external onlyOwner {
        initialAmount = _initialAmount;
        replenishAmount = _replenishAmount;
        replenishDuration = _replenishDuration;
    }

    /**
     * @notice This method is used to claim tokens initially or when replenished
     */
    function claimTokens()
        external
        whenNotPaused
        returns (uint256 claimAmount)
    {
        if (userLastClaim[msg.sender] != 0) {
            require(isReplenishable, "Cryptopati: token replenish is paused");
            require(
                block.timestamp - userLastClaim[msg.sender] >=
                    replenishDuration,
                "Cryptopati: wait replenish duration to claim more tokens"
            );
            claimAmount = replenishAmount;
        } else {
            require(isInitialClaimable, "Cryptopati: initial claim is paused");
            claimAmount = initialAmount;
        }
        userLastClaim[msg.sender] = block.timestamp;
        accuCoin.mint(msg.sender, claimAmount);
        emit ClaimTokens(msg.sender, claimAmount);
    }

    /**
     * @notice This method is used to check if a question exist
     * @param questionId ID of the question
     */
    function questionExist(string calldata questionId)
        public
        view
        returns (bool)
    {
        return _questions[questionId].exist;
    }

    /**
     * @notice This method is used to get question details
     * @param questionId ID of the question
     */
    function getQuestion(string calldata questionId)
        external
        view
        onlyValid(questionId)
        returns (Question memory)
    {
        return _questions[questionId];
    }

    /**
     * @notice This method is used to get question details
     * @param questionId ID of the question
     */
    function addQuestion(string calldata questionId, uint256 multiplier)
        external
        onlyOwner
    {
        require(
            !_questions[questionId].exist,
            "Cryptopati: questionId already added"
        );

        _questions[questionId] = Question(multiplier, true);

        emit QuestionAdd(questionId);
    }

    /**
     * @notice This method is used to unlock the question
     * @param questionId ID of the question
     * @param commitAmount Amount user invests to unlock the question
     */
    function unlockQuestion(string calldata questionId, uint256 commitAmount)
        external
        whenNotPaused
        onlyValid(questionId)
    {
        require(
            userToQuestionId[msg.sender][questionId].unlockTimestamp == 0,
            "Cryptopati: Question already unlocked"
        );
        require(commitAmount != 0, "Cryptopati: Commit Amount Zero");

        userToQuestionId[msg.sender][questionId].commitAmount = commitAmount;
        userToQuestionId[msg.sender][questionId].unlockTimestamp = block
            .timestamp;

        userInfo[msg.sender].totalCommitAmount += commitAmount;

        accuCoin.transferFrom(msg.sender, address(this), commitAmount);

        emit UnlockQuestion(msg.sender, questionId, commitAmount);
    }

    /**
     * @notice This method is used to transfer reward if answer is correct
     * @param questionId ID of the question
     * @param _addressUser address of the user to sent reward
     */
    function winQuestion(string calldata questionId, address _addressUser)
        external
        onlyValid(questionId)
    {
        require(msg.sender == platform, "Cryptopati: only platform");
        require(
            userToQuestionId[_addressUser][questionId].unlockTimestamp != 0,
            "Cryptopati: Question not unlocked"
        );
        require(
            userToQuestionId[_addressUser][questionId].collectedAmount == 0,
            "Cryptopati: Question already processed"
        );

        uint256 userCommitAmount = userToQuestionId[_addressUser][questionId]
            .commitAmount;
        uint256 userCollectedAmount = userCommitAmount *
            _questions[questionId].multiplier;
        multiplierAmount = userCollectedAmount - userCommitAmount;
        userToQuestionId[_addressUser][questionId]
            .collectedAmount = userCollectedAmount;

        userInfo[_addressUser].totalAmountCollected += userCollectedAmount;
        accuCoin.mint(_addressUser, multiplierAmount);
        accuCoin.transfer(_addressUser, userCommitAmount);
        emit WinQuestion(_addressUser, questionId, userCollectedAmount);
    }
}
