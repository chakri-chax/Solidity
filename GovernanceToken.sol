// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract GovernanceToken is ERC20, Pausable, ReentrancyGuard, Ownable,ERC20Permit,ERC20Votes {
    mapping(address => uint256) public userStakedBalance;

    uint8 private _decimals;

    struct smartContractActions {
        bool canMint;
        bool canBurn;
        bool canPause;
        bool canStake;
        bool canTransfer;
        bool canChangeOwner;
    }
    smartContractActions public actions;

    modifier canMintModifier() {
        require(
            actions.canMint,
            "Minting Functionality is not enabled in this smart contract!"
        );
        _;
    }

    modifier canBurnModifier() {
        require(
            actions.canBurn,
            "Burning Functionality is not enabled in this smart contract!"
        );
        _;
    }

    modifier canPauseModifier() {
        require(
            actions.canPause,
            "Pause/Unpause Functionality is not enabled in this smart contract!"
        );
        _;
    }

    modifier canStakeModifier() {
        require(
            actions.canStake,
            "Staking reward Functionality is not enabled in this smart contract!"
        );
        _;
    }
    modifier  canTransfer(){
        require(actions.canTransfer,"Transfer Functionality is not enabled in this smart contract!");
        _;
    }


    modifier canChangeOwner(){
         require(actions.canChangeOwner,"Change Owner Functionality is not enabled in this smart contract!");
        _;
    }

    mapping(address => address) public daoAddress;
    
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address _initialAddress,
        uint8 decimals,
        smartContractActions memory _actions
    ) ERC20(name, symbol) Ownable(_initialAddress)ERC20Permit(name) {
        _mint(msg.sender, initialSupply * decimalCal());
        daoAddress[address(this)] = address(0);
        initializeFeatures(_actions);
        _decimals=decimals;
    }

    function decimalCal() private view returns (uint256){
        return (10 ** _decimals);
    }

    function initializeFeatures(smartContractActions memory _actions) internal {
        actions.canStake = _actions.canStake;
        actions.canBurn = _actions.canBurn;
        actions.canMint = _actions.canMint;
        actions.canPause = _actions.canPause;
        actions.canTransfer = _actions.canTransfer;
    }

    function mintSupply(address to,uint256 _amount) public canMintModifier nonReentrant whenNotPaused{
        _mint(to, _amount*decimalCal());
    }

    function burnSupply(address from,uint256 _amount) public canBurnModifier nonReentrant whenNotPaused{
        _burn(from, _amount*decimalCal());
    }
    function transfer(address recipient, uint  amount)  public canTransfer nonReentrant whenNotPaused override returns (bool){
        _transfer(msg.sender, recipient, amount*decimalCal());
        return true;
    }


    function stakeToken(uint256 _amount) public canStakeModifier nonReentrant whenNotPaused{
        uint256 decimalAmount = _amount*decimalCal();
        require(balanceOf(msg.sender) >= decimalAmount, "Insufficient token balance to stake");
        _transfer(msg.sender, address(this), decimalAmount);
        userStakedBalance[msg.sender] += decimalAmount;
    }


    function setDaoAddress(address _addr) public onlyOwner {
        require(daoAddress[address(this)] == address(0),"Dao address already set");
        daoAddress[address(this)] = _addr;
    }

    function pause() public canPauseModifier whenNotPaused {
        require(!paused(), "Contract is already paused.");
        _pause();
    }
    
    function unpause() public canPauseModifier whenPaused {
        require(paused(), "Contract is not paused.");
        _unpause();
    }

    function changeTokenOwner(address _newOwner) public onlyOwner canChangeOwner{
        require(_newOwner != address(0), "New owner is the zero address");
        require(owner()!=_newOwner, "Provided User is already an Owner");
        transferOwnership(_newOwner);
    }

    function _update (address from, address to, uint256 value) internal whenNotPaused override(ERC20, ERC20Votes) {
        super._update(from, to, value);
    }

    function nonces(address owner)
        public
        view
        override(ERC20Permit, Nonces)
        returns (uint256)
    {
        return super.nonces(owner);
    }
}
