// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.6;
pragma experimental ABIEncoderV2;

import { IERC20 } from "../interfaces/InterfacesAggregated.sol";

contract Actor {

    /************************/
    /*** DIRECT FUNCTIONS ***/
    /************************/

    function transferToken(address token, address to, uint256 amt) external returns (bool ok){
        assert(IERC20(token).transfer(to, amt));
        return true;
    }

    /*********************/
    /*** TRY FUNCTIONS ***/
    /*********************/

    // ~ BloomToken ~

    function try_transferToken(address token, address to, uint256 amount) external returns (bool ok) {
        string memory sig = "transfer(address,uint256)";
        (ok,) = address(token).call(abi.encodeWithSignature(sig, to, amount));
    }

    function try_transferFromToken(address token, address from, address to, uint256 amount) external returns (bool ok) {
        string memory sig = "transferFrom(address,address,uint256)";
        (ok,) = address(token).call(abi.encodeWithSignature(sig, to, amount));
    }

    function try_approveToken(address token, address to, uint256 amount) external returns (bool ok) {
        string memory sig = "approve(address,uint256)";
        (ok,) = address(token).call(abi.encodeWithSignature(sig, to, amount));
    }

    function try_updateException(address token, address wallet, bool isException) external returns (bool ok) {
        string memory sig = "updateException(address,bool)";
        (ok,) = address(token).call(abi.encodeWithSignature(sig, wallet, isException));

    }

    function try_mint(address token, address account, uint amt) external returns (bool ok) {
        string memory sig = "mint(address,uint256)";
        (ok,) = address(token).call(abi.encodeWithSignature(sig, account, amt));
    }

    function try_setTreasury(address token, address treasury) external returns (bool ok) {
        string memory sig = "setTreasury(address)";
        (ok,) = address(token).call(abi.encodeWithSignature(sig, treasury));
    }

    // ~ swapInterface ~

    function try_updateStableReceived(address treasury, address _wallet, uint256 _amount, uint256 _timeUnix) external returns (bool ok) {
        string memory sig = "updateStableReceived(address,uint256,uint256)";
        (ok,) = address(treasury).call(abi.encodeWithSignature(sig, _wallet, _amount, _timeUnix));
    }

    function try_mintBloom(address treasury, address wallet, uint256 amount) external returns (bool ok) {
        string memory sig = "mintBloom(address,uint256)";
        (ok,) = address(treasury).call(abi.encodeWithSignature(sig, wallet, amount));
    }

    function try_addWalletToAuthorizedUsers(address swapInterface, address _address) external returns (bool ok) {
        string memory sig = "addAuthorizedUser(address)";
        (ok,) = address(swapInterface).call(abi.encodeWithSignature(sig, _address));
    }

    function try_removeWalletFromAuthorizedUsers(address swapInterface, address _address) external returns (bool ok) {
        string memory sig = "removeAuthorizedUser(address)";
        (ok,) = address(swapInterface).call(abi.encodeWithSignature(sig, _address));
    }

    function try_addWalletToWhitelist(address swapInterface, address _address) external returns (bool ok) {
        string memory sig = "addWalletToWhitelist(address)";
        (ok,) = address(swapInterface).call(abi.encodeWithSignature(sig, _address));
    }

    function try_removeWalletFromWhitelist(address swapInterface, address _address) external returns (bool ok) {
        string memory sig = "removeWalletFromWhitelist(address)";
        (ok,) = address(swapInterface).call(abi.encodeWithSignature(sig, _address));
    }

    function try_changeStableCurrency(address swapInterface, address _address) external returns (bool ok) {
        string memory sig = "changeStableCurrency(address)";
        (ok,) = address(swapInterface).call(abi.encodeWithSignature(sig, _address));
    }

    function try_enableContract(address swapInterface) external returns (bool ok) {
        string memory sig = "enableContract()";
        (ok,) = address(swapInterface).call(abi.encodeWithSignature(sig));
    }

    function try_disableContract(address swapInterface) external returns (bool ok) {
        string memory sig = "disableContract()";
        (ok,) = address(swapInterface).call(abi.encodeWithSignature(sig));
    }

    function try_updateTokenWhitelist(address swapInterface, address _tokenAddress, bool _allowed) external returns (bool ok) {
        string memory sig = "updateTokenWhitelist(address,bool)";
        (ok,) = address(swapInterface).call(abi.encodeWithSignature(sig, _tokenAddress, _allowed));
    }

    function try_invest(address swapInterface, address _tokenAddress, uint256 _amount) external returns (bool ok) {
        string memory sig = "invest(address,uint256)";
        (ok,) = address(swapInterface).call(abi.encodeWithSignature(sig, _tokenAddress, _amount));
    }

    function try_investETH(address swapInterface) external payable returns (bool ok) {
        string memory sig = "investETH()";
        (ok,) = address(swapInterface).call{value: msg.value}(abi.encodeWithSignature(sig));
    }

    function try_updateTreasury(address swapInterface, address _newAddress) external returns (bool ok) {
        string memory sig = "updateTreasury(address)";
        (ok,) = address(swapInterface).call(abi.encodeWithSignature(sig, _newAddress));
    }

    // ~ treasury ~
        
    function try_addAuthorizedUser(address treasury, address wallet) external returns (bool ok) {
        string memory sig = "addAuthorizedUser(address)";
        (ok,) = address(treasury).call(abi.encodeWithSignature(sig, wallet));
    }

    function try_removeAuthorizedUser(address treasury, address wallet) external returns (bool ok) {
        string memory sig = "removeAuthorizedUser(address)";
        (ok,) = address(treasury).call(abi.encodeWithSignature(sig, wallet));
    }

    function try_updateStableCurrency(address treasury, address stable) external returns (bool ok) {
        string memory sig = "updateStableCurrency(address)";
        (ok,) = address(treasury).call(abi.encodeWithSignature(sig, stable));
    }

    function try_safeWithdraw(address treasury, address _token) external returns (bool ok) {
        string memory sig = "safeWithdraw(address)";
        (ok,) = address(treasury).call(abi.encodeWithSignature(sig, _token));
    }

    function try_updateSwapInterface(address treasury, address wallet) external returns (bool ok) {
        string memory sig = "updateSwapInterface(address)";
        (ok,) = address(treasury).call(abi.encodeWithSignature(sig, wallet));
    }

    function try_updateBloomToken(address treasury, address _token) external returns (bool ok) {
        string memory sig = "updateBloomToken(address)";
        (ok,) = address(treasury).call(abi.encodeWithSignature(sig, _token));
    }

}