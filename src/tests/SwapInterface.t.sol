// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../../lib/ds-test/src/test.sol";

import "./Utility.sol";

import "../SwapInterface.sol";

contract SwapInterfaceTest is DSTest, Utility {
    SwapInterface swapInterface;

    function setUp() public {
        createActors();

        swapInterface = new SwapInterface(
            USDC,
            address(dev)
        );

        dev.try_addWalletToAuthorizedUsers(address(swapInterface), address(val));
        dev.try_addWalletToWhitelist(address(swapInterface), address(bob));
    }


    // ~ Authorized Users ~

    // addAuthorizedUser state changes
    function test_addAuthorizedUser() public {
        // pre-state
        assert(!swapInterface.isAuthorizedUser(address(joe)));

        // state change
        assert(dev.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe)));

        // post-state
        assert(swapInterface.isAuthorizedUser(address(joe)));
    }

    // addAuthorizedUser restrictions
    function test_addAuthorizedUser_restriction() public {
        // "joe" should not be able to call addAuthorizedUser().
        assert(!joe.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe)));

        // "bob" should not be able to call addAuthorizedUser().
        assert(!bob.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe)));

        // "val" should not be able to call addAuthorizedUser().
        assert(!val.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe)));

        // "dev" should be able to call addAuthorizedUser().
        assert(dev.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe)));
    }

    // removeAuthorizedUser state changes
    function test_removeAuthorizedUser() public {
        // pre-state
        assert(swapInterface.isAuthorizedUser(address(val)));

        // state change
        assert(dev.try_removeWalletFromAuthorizedUsers(address(swapInterface), address(val)));
        
        // post-state
        assert(!swapInterface.isAuthorizedUser(address(val)));
    }

    // removeAuthorizedUser restrictions
    function test_removeAuthorizedUser_restriction() public {
        // "joe" should not be able to call removeAuthorizedUser().
        assert(!joe.try_removeWalletFromAuthorizedUsers(address(swapInterface), address(joe)));

        // "bob" should not be able to call removeAuthorizedUser().
        assert(!bob.try_removeWalletFromAuthorizedUsers(address(swapInterface), address(joe)));

        // "val" should not be able to call removeAuthorizedUser().
        assert(!val.try_removeWalletFromAuthorizedUsers(address(swapInterface), address(joe)));

        // "dev" should be able to call removeAuthorizedUser().
        assert(dev.try_removeWalletFromAuthorizedUsers(address(swapInterface), address(joe)));
    }

    // ~ Whitelists

    // addWalletToWhitelist state changes
    function test_addWalletToWhitelist() public {
        //Pre state
        assert(!swapInterface.whitelistedWallet(address(joe)));

        //State change
        assert(dev.try_addWalletToWhitelist(address(swapInterface), address(joe)));

        //Post state
        assert(swapInterface.whitelistedWallet(address(joe)));

    }

    // addWalletToWhitelist restrictions
    function test_addWalletToWhitelist_restriction() public {
        // "joe" should not be able to call addWalletToWhitelist().
        assert(!joe.try_addWalletToWhitelist(address(swapInterface), address(joe)));

        // "bob" should not be able to call addWalletToWhitelist().
        assert(!bob.try_addWalletToWhitelist(address(swapInterface), address(joe)));

        // "val" should be able to call addWalletToWhitelist().
        assert(val.try_addWalletToWhitelist(address(swapInterface), address(joe)));

        // "dev" should be able to call addWalletToWhitelist().
        assert(dev.try_addWalletToWhitelist(address(swapInterface), address(joe)));

    }

    // removeWalletFromWhitelist state changes
    function test_removeWalletFromWhitelist() public {
        // pre-state
        assert(swapInterface.whitelistedWallet(address(bob)));

        // state change
        assert(dev.try_removeWalletFromWhitelist(address(swapInterface), address(bob)));

        // post-state
        assert(!swapInterface.whitelistedWallet(address(bob)));
    }

    // removeWalletFromWhitelist restrictions
    function test_removeWalletFromWhitelist_restriction() public {
        // "joe" should not be able to call removeWalletFromWhitelist().
        assert(!joe.try_removeWalletFromWhitelist(address(swapInterface), address(joe)));

        // "bob" should not be able to call removeWalletFromWhitelist().
        assert(!bob.try_removeWalletFromWhitelist(address(swapInterface), address(joe)));

        // "val" should be able to call removeWalletFromWhitelist().
        assert(val.try_removeWalletFromWhitelist(address(swapInterface), address(joe)));

        // "dev" should be able to call removeWalletFromWhitelist().
        assert(dev.try_removeWalletFromWhitelist(address(swapInterface), address(joe)));
    }

    // ~ Stable Currency

    // change stable currency state changes
    function test_changeStableCurrency() public {
        // pre-state
        assertEq(swapInterface.stableCurrency(), USDC);

        // state change
        assert(dev.try_changeStableCurrency(address(swapInterface), address(1)));

        // post-state
        assertEq(swapInterface.stableCurrency(), address(1));
    }

    // change stable currency restrictions
    function test_changeStableCurrency_restriction() public {
        // "joe" should not be able to call changeStableCurrency().
        assert(!joe.try_changeStableCurrency(address(swapInterface), address(1)));

        // "bob" should not be able to call changeStableCurrency().
        assert(!bob.try_changeStableCurrency(address(swapInterface), address(1)));

        // "val" should not be able to call changeStableCurrency().
        assert(!val.try_changeStableCurrency(address(swapInterface), address(1)));

        // "dev" should be able to call changeStableCurrency().
        assert(dev.try_changeStableCurrency(address(swapInterface), address(1)));
    }

    // ~ Contract Enable/Disable

    // enable contract state changes
    function test_enableContract() public {
        // pre-state
        assertTrue(!swapInterface.contractEnabled());

        // state change
        assert(dev.try_enableContract(address(swapInterface)));

        // post-state
        assertTrue(swapInterface.contractEnabled());
    }

    // enable contract restrictions
    function test_enableContract_restriction() public {
        // "joe" should not be able to call enableContract().
        assert(!joe.try_enableContract(address(swapInterface)));

        // "bob" should not be able to call enableContract().
        assert(!bob.try_enableContract(address(swapInterface)));

        // "val" should not be able to call enableContract().
        assert(!val.try_enableContract(address(swapInterface)));

        // "dev" should be able to call enableContract().
        assert(dev.try_enableContract(address(swapInterface)));

    }

    // disable contract state changes
    function test_disableContract() public {
        // pre-state
        assertTrue(!swapInterface.contractEnabled());

        // state change
        assert(dev.try_disableContract(address(swapInterface)));

        // post-state
        assertTrue(!swapInterface.contractEnabled());
    }

    // disable contract restrictions
    function test_disableContract_restriction() public {
        // "joe" should not be able to call disableContract().
        assert(!joe.try_disableContract(address(swapInterface)));

        // "bob" should not be able to call disableContract().
        assert(!bob.try_disableContract(address(swapInterface)));

        // "val" should not be able to call disableContract().
        assert(!val.try_disableContract(address(swapInterface)));

        // "dev" should be able to call disableContract().
        assert(dev.try_disableContract(address(swapInterface)));

    }

    // ~ Token Whitelist

    // update token whitelist state changes
    function test_updateTokenWhitelist() public {
        // pre-state
        assert(!swapInterface.whitelistedToken(address(1)));

        // state change
        assert(dev.try_updateTokenWhitelist(address(swapInterface), address(1), true));

        // post-state
        assert(swapInterface.whitelistedToken(address(1)));

    }

    // update token whitelist restrictions
    function test_updateTokenWhitelist_restriction() public {
        // "joe" should not be able to call updateTokenWhitelist().
        assert(!joe.try_updateTokenWhitelist(address(swapInterface), address(1), true));

        // "bob" should not be able to call updateTokenWhitelist().
        assert(!bob.try_updateTokenWhitelist(address(swapInterface), address(1), true));

        // "val" should not be able to call updateTokenWhitelist().
        assert(!val.try_updateTokenWhitelist(address(swapInterface), address(1), true));

        // "dev" should be able to call updateTokenWhitelist().
        assert(dev.try_updateTokenWhitelist(address(swapInterface), address(1), true));
    }
}
