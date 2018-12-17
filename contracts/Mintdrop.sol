pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";

import "./AbstractRootChain.sol";
import "./Ownable.sol";

/**
 * Continuous airdrop where recipients can withdraw tokens allocated in side-chain.
 * Dropped tokens are minted, not deposited in advance.
 */
contract Airdrop is AbstractRootChain, Ownable {
    using SafeMath for uint256;

    ERC20Mintable public token;
    mapping (address => uint) public withdrawn;

    constructor(address tokenAddress, uint blockFreezePeriodSeconds)
        AbstractRootChain(blockFreezePeriodSeconds)
        Ownable() public {
        token = ERC20Mintable(tokenAddress);
    }

    /**
     * Owner creates the side-chain blocks
     */
    function canRecordBlock(uint, bytes32, string) internal returns (bool) {
        return msg.sender == owner;
    }

    /**
     * Called from AbstractRootChain.proveSidechainBalance, perform payout directly
     */
    function onVerifySuccess(address account, uint balance) internal {
        require(withdrawn[account] < balance, "err_oldEarnings");
        uint withdrawable = balance.sub(withdrawn[account]);
        withdrawn[account] = balance;
        require(token.mint(account, withdrawable), "err_transfer");
    }
}