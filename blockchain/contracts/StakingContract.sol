// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingContract is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardToken;
    
    uint256 public constant PRECISION = 1e18;

    uint256 public totalStaked;

    mapping (address => uint256) public balanceOf;

    uint256 public rewardRate;
    uint256 public rewardPerTokenStored;
    uint256 public lastUpdateTime;
    uint256 public periodFinish;
    
    mapping (address => uint256) public userRewardPerTokenPaid;
    mapping (address => uint256) public rewards;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    event RewardNotified(uint256 rewardAmount, uint256 duration, uint256 rewardRate);

    constructor(address _stakingToken, address _rewardToken) Ownable(msg.sender) {
        require(_stakingToken != address(0), "Staking address cant be empty");
        require(_rewardToken != address(0), "Reward address cant be empty");
        require(_stakingToken != _rewardToken, "Staking and Reward addresses cant be same");

        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        if (block.timestamp < periodFinish) {
            return block.timestamp;
        } else {
            return periodFinish;
        }
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) return rewardPerTokenStored;

        uint256 timeDelta = lastTimeRewardApplicable() - lastUpdateTime;
        uint256 rewardIncrease = timeDelta * rewardRate;
        uint256 perTokenIncrease = (rewardIncrease * PRECISION) / totalStaked;

        return rewardPerTokenStored + perTokenIncrease;
    }

    function earned(address account) public view returns (uint256) {
        return
            (balanceOf[account] *
                (rewardPerToken() - userRewardPerTokenPaid[account])) / 
            PRECISION +
            rewards[account];
    }

    function updateReward(address account) internal {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();

        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
    }

    function stake(uint256 amount) external nonReentrant {
        require (amount > 0, "Staking amount should be greater than 0");

        updateReward(msg.sender);

        stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        balanceOf[msg.sender] += amount;
        totalStaked += amount;

        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) external nonReentrant {
        require (amount > 0, "Withdraw amount should be greater than 0");
        require (balanceOf[msg.sender] >= amount, "Withdraw amount should be less than or equal to available balance");

        updateReward(msg.sender);

        balanceOf[msg.sender] -= amount;
        totalStaked -= amount;

        stakingToken.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

     function claimReward() external nonReentrant {
        updateReward(msg.sender);

        uint256 reward = rewards[msg.sender];
        require(reward > 0, "No rewards to claim");

        rewards[msg.sender] = 0;
        rewardToken.safeTransfer(msg.sender, reward);

        emit RewardPaid(msg.sender, reward);
     }

     function notifyRewardAmount(uint256 rewardAmount, uint256 duration) external onlyOwner {
        require(duration > 0, "Duration must be > 0");
        require(rewardAmount > 0, "Reward amount must be > 0");

        updateReward(address(0));

        uint256 currentTime = block.timestamp;

        if (currentTime < periodFinish) {
            uint256 remaining = periodFinish - currentTime;
            uint256 leftover = remaining * rewardRate;
            rewardAmount += leftover;
        }

        uint256 balance = rewardToken.balanceOf(address(this));
        require(balance >= rewardAmount, "Not enough reward tokens funded");

        rewardRate = rewardAmount / duration;
        require(rewardRate > 0, "Reward rate is zero");

        lastUpdateTime = currentTime;
        periodFinish = currentTime + duration;

        emit RewardNotified(rewardAmount, duration, rewardRate);
     }
}