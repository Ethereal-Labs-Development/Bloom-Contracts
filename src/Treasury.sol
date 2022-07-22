// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "./OpenZeppelin/Ownable.sol";
import { IERC20 } from "./interfaces/InterfacesAggregated.sol";

/// @dev    The Treasury contract will be the focal point within the protocol.
///         This contract will keep track of all accounting
///         It will account for all assets, investors, and dividends for all
///         projects within the Bloom Project.
///         This contract calls mint() on BloomToken.sol
///         This contract recieves USDC or other stablecoins from SwapInterface.sol
///         This contract tracks all BTC invested into the Circle acc. updateBtcReceived() called by bot.
///         This contract also can send USDC or other stablecoin to our Circle acc.
///         To be determined:
///          - What values we need to return for front end?
///          - Are we keeping track of projects or just investments?
///          - How do we know which wallets are finished receiving dividends?
///          - How will funds be deposited for dividends?
///          - Will we ever remove data from the mappings: ie, how does a project end.
contract Treasury is Ownable {

    // ---------------
    // State Variables
    // ---------------

    address public stableCurrency;           /// @notice Used to store address of coin used to deposit/payout from Treasury.
    address public swapInterfaceContract;    /// @notice Used to store the address of SwapInterface.sol
    address public bloomToken;               /// @notice Used to store the address of the Bloom Token.
   

    // TODO: Consider making investorLibrary private -> write get functions for investorData points
    mapping(address => InvestorData) public investorLibrary;     /// @notice Mapping of Investor wallets to their investment data held in InvestorData.
    address[] public authorizedUsers;                            /// @notice Array of addresses that are authorized Bloom Admins.

    /// @notice Investor struct is used to track data points of investments made by investors.
    /// @param amountInvested Tracks USD-stablecoin equivalent to investment made.
    /// @param dividendsReceived Tracks dividends received by investor in stablecoin.
    struct InvestorData {
        uint totalAmountInvested;
        uint totalDividendsReceived;
        InvestmentReceipt[] investmentLibrary;
        DividendReceipt[] dividendLibrary;
    }

    /// @notice InvestmentReceipt is used to track the amount invested by an indiviual investor and the time unix each transaction occurs.
    /// @param amountInvested Stores the amount an individual invest.
    /// @param timeUnix Stores the timestamp when transaction occured.
    struct InvestmentReceipt {
        uint amountInvested;
        uint timeUnix;
    }

    /// @notice Dividend Struct is used to track the amount of dividends an investor is paid and the timestamp each transaction occurs.
    /// @param dividendPaid Stores the amount of dividends paid to an investor.
    /// @param timeUnix Stores the timestamp transaction occured.
    struct DividendReceipt {
        uint dividendPaid;
        uint timeUnix;
    }

    // -----------
    // Constructor
    // -----------

    /// @notice Initializes Treasury.sol 
    /// @param _stableCurrency Used to store address of stablecoin used in contract (default is USDC).
    constructor (
        address _stableCurrency,
        address _swapInterface,
        address _bloomToken,
        address _admin
    ) {
        stableCurrency = _stableCurrency;
        swapInterfaceContract = _swapInterface;
        bloomToken = _bloomToken;

        transferOwnership(_admin);
        authorizedUsers.push(owner());
    }

    // ------
    // Events
    // ------

    // TODO: Add any necessary events. An event is simply a log that takes place
    //       when something in the contract happens we feel is important enough to emit it.
    //       https://www.tutorialspoint.com/solidity/solidity_events.htm.

    event StableCoinReceived(address indexed wallet, uint amount);
    
    // ---------
    // Modifiers
    // ---------

    // TODO: Add a modifier called isAuthorizedUser that checks to see if msg.sender is an authorizedUser.
    //       https://www.tutorialspoint.com/solidity/solidity_function_modifiers.htm.

    modifier isSwapInterface {
        require(msg.sender == swapInterfaceContract, "Treasury.sol::isSwapInterface() msg.sender != SwapInterface.sol");
        _;
    }
    
     
    // ---------
    // Functions
    // ---------

    /// @notice Withdraw stableCurrency from contract to a Circle acc.
    function withdrawToCircle() public {

    }

    /// @notice Updates investment values when a BTC investment is made.
    /// @dev    Function called by python bot.
    function updateBtcReceived() public {

    }

    /// TODO:   Add SwapInterface modifier.
    /// @notice Updates investment values when an investment is made through Dapp.
    /// @dev    Should only be called by SwapInterface.sol.
    /// @param _wallet account making an investment.
    /// @param _amount amount of stable coin received from account.
    /// @param _timeUnix time unix of when investment occured.
    function updateStableReceived(address _wallet, uint _amount, uint _timeUnix) public isSwapInterface{
        emit StableCoinReceived(_wallet, _amount);
        investorLibrary[_wallet].totalAmountInvested += _amount;
        investorLibrary[_wallet].investmentLibrary.push(InvestmentReceipt(_amount, _timeUnix));
        //mintBloom
    }

    /// @notice Mints BLOOM tokens to a certain investor.
    /// @dev    Calls BloomToken.sol::mint().
    /// @param _wallet The account to mint tokens for.
    /// @param _amount The amount of Bloom tokens to mint for account.
    function mintBloom(address _wallet, uint256 _amount) internal {
        IERC20(bloomToken).mint(_wallet, _amount);
    }

    /// @notice Allows the contract owner to add authorized wallets to the authorizedUser[] array.
    /// @param _wallet contains wallet address we wish to add to the authorizesUers[] array.
    function addAuthorizedUser(address _wallet) public onlyOwner() {
        require(!getAuthorizedUser(_wallet), "Treasury.sol::addAuthorizedUser() wallet is already an authorizedUser");
        authorizedUsers.push(_wallet);
    }

        /// @notice This function gets the number of wallets inside the authorizedUsers array.
    /// @return uint Number of wallets inside array.
    function getNumOfAuthorizedUsers() public view returns (uint) {
        return authorizedUsers.length;
    }

    /// @notice Allows the contract owner to remove authorized wallets from the authorizedUser[] array.
    /// @param _wallet contains wallet address we wish to remove to the authorizedUsers[] array.
    function removeAuthorizedUser(address _wallet) public onlyOwner() {
        require(getAuthorizedUser(_wallet), "Treasury.sol::removeAuthorizedUser() wallet does not exist within authorizedUser[]");

        uint gap;

        for (uint i = 0; i < getNumOfAuthorizedUsers(); i++) {
            if (_wallet == authorizedUsers[i]) {
                delete authorizedUsers[i];
                gap = i;
            }
        }
        for (uint i = gap; i < getNumOfAuthorizedUsers() - 1; i++) {
            authorizedUsers[1] = authorizedUsers[i + 1];
        }
        authorizedUsers.pop();
    }



    /// @notice Function returns a boolean on whether the wallet is added to the authorizedUsers[] array.
    /// @param  _wallet The wallet address we wish to know is or is not inside the array.
    /// @return bool true if wallet is inside the array, otherwise false.
    function getAuthorizedUser(address _wallet) public view returns (bool) {
        if (getNumOfAuthorizedUsers() > 0) {
            for (uint i = 0; i < getNumOfAuthorizedUsers(); i++) {
                if (authorizedUsers[i] == _wallet) {
                    return true;
                }
            }
        } else {
            return false;
        }
        return false;
    }

    /// @notice Withdraws asset to owner wallet.
    /// @param _token is the contract address of token we want to withdraw.
    function safeWithdraw(address _token) public onlyOwner() {

    }

    /// @notice Deposit assets into the contract
    /// @param _token is the contract address of token we want to withdraw.
    function safeDeposit(address _token) public onlyOwner() {

    }

    /// @notice Pays dividends to the investor.
    function payDividends() public onlyOwner() returns(uint) {

    }

    /// @notice updates stablecurrency to _stablecurrency.
    /// @param _stableCurrency stores stableCurrency.
    function updateStableCurrency(address _stableCurrency) public onlyOwner() {
        stableCurrency = _stableCurrency;
    }

    /// @notice updates swapInterfaceContract.
    /// @param _newSwapInterface stores contract address of SwapInterface.sol.
    function updateSwapInterface(address _newSwapInterface) public onlyOwner() {
        swapInterfaceContract = _newSwapInterface;
    }

    /// @notice deposits dividend payment to a depository.
    /// @param  _amntDividends stores the amount of dividends to be paid to an investor.
    function depositDividends(uint _amntDividends) public onlyOwner() {

    }


    // ~ View Functions ~

    /// @notice Should return contract balance of stableCurrency.
    /// @return uint Amount of stableCurrency that is inside contract.
    function balanceOfStableCurrency() public view returns (uint) {

    }

    /// @notice used to get the InvestorData of a specific wallet.
    /// @param  _wallet wallet of investor whose InvestorData we want to get.
    /// @return InvestorData returns struct of info pertaining to investor's data.
    function getInvestorData(address _wallet) public view returns (InvestorData memory) {
        return investorLibrary[_wallet];
    }

    /// @notice used to get InvestmentReceipt[] of a specific account.
    /// @param  _wallet wallet of investor whose InvestmentReceipt[] we want to return.
    /// @return InvestmentReceipt[] array of investments made by this wallet.
    function getInvestmentLibrary(address _wallet) public view returns (InvestmentReceipt[] memory) {
        return investorLibrary[_wallet].investmentLibrary;
    }

    /// @notice used to get DividendReceipt[] of a specific account.
    /// @param  _wallet wallet of investor whose DividendReceipt[] we want to return.
    /// @return DividendReceipt[] array of dividends received by this wallet.
    function getDividendLibrary(address _wallet) public view returns (DividendReceipt[] memory) {
        return investorLibrary[_wallet].dividendLibrary;
    }
}
