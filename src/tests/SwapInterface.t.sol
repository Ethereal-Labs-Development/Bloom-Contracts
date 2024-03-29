// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../../lib/ds-test/src/test.sol";

import "./Utility.sol";

import "../SwapInterface.sol";

import "../Treasury.sol";

import "../BloomToken.sol";

import { IUniswapV2Router01, IWETH } from "../interfaces/InterfacesAggregated.sol";

contract SwapInterfaceTest is DSTest, Utility {
    SwapInterface swapInterface;
    Treasury treasury;
    BloomToken bloomToken;

    function setUp() public {
        createActors();
        setUpTokens();

        swapInterface = new SwapInterface(
            USDC,
            address(dev)
        );

        bloomToken = new BloomToken(
            0, // NOTE: DO NOT ADD 18 ZEROS, when deployed set to 0
            18,
            "BloomToken",
            "BLOOM",
            address(dev)
        );

        treasury = new Treasury(
            USDC,
            address(swapInterface),
            address(bloomToken),
            address(dev)
        );

        dev.try_addWalletToAuthorizedUsers(address(swapInterface), address(val));
        dev.try_addWalletToWhitelist(address(swapInterface), address(bob));
        dev.try_updateTreasury(address(swapInterface), address(treasury));
        dev.try_enableContract(address(swapInterface));
        dev.try_setTreasury(address(bloomToken), address(treasury));
    }

    function test_swapInterface_init_state() public {
        assertEq(swapInterface.stableCurrency(), USDC);
        assertEq(swapInterface.owner(), address(dev));
        assertTrue(swapInterface.isAuthorizedUser(address(val)));
        assertTrue(swapInterface.whitelistedWallet(address(bob)));
    }


    // ~ addAuthorizedUser() Testing ~

    // addAuthorizedUser state changes.
    function test_swapInterface_addAuthorizedUser_state_changes() public { 
        // pre-state
        assert(!swapInterface.isAuthorizedUser(address(joe)));

        // state change
        assert(dev.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe)));

        // post-state
        assert(swapInterface.isAuthorizedUser(address(joe)));
    }

    // addAuthorizedUser restrictions.
    function test_swapInterface_addAuthorizedUser_restrictions() public {
        // "joe" should not be able to call addAuthorizedUser().
        assert(!joe.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe)));

        // "bob" should not be able to call addAuthorizedUser().
        assert(!bob.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe)));

        // "val" should not be able to call addAuthorizedUser().
        assert(!val.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe)));

        // "dev" should be able to call addAuthorizedUser().
        assert(dev.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe)));


        // should not be able to add
        assert(!dev.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe)));
    }

    // ~ removeAuthorizedUser() Testing ~

    // removeAuthorizedUser state changes.
    function test_swapInterface_removeAuthorizedUser_state_changes() public {
        // pre-state
        assert(swapInterface.isAuthorizedUser(address(val)));

        // state change
        assert(dev.try_removeWalletFromAuthorizedUsers(address(swapInterface), address(val)));
        
        // post-state
        assert(!swapInterface.isAuthorizedUser(address(val)));
    }

    // removeAuthorizedUser restrictions.
    function test_swapInterface_removeAuthorizedUser_restrictions() public {
        // setup: add joe to authorized users list.
        dev.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe));


        // "joe" should not be able to call removeAuthorizedUser().
        assert(!joe.try_removeWalletFromAuthorizedUsers(address(swapInterface), address(joe)));

        // "bob" should not be able to call removeAuthorizedUser().
        assert(!bob.try_removeWalletFromAuthorizedUsers(address(swapInterface), address(joe)));

        // "val" should not be able to call removeAuthorizedUser().
        assert(!val.try_removeWalletFromAuthorizedUsers(address(swapInterface), address(joe)));

        // "dev" should be able to call removeAuthorizedUser().
        assert(dev.try_removeWalletFromAuthorizedUsers(address(swapInterface), address(joe)));


        // should not be able to remove users that have already been removed.
        assert(!dev.try_removeWalletFromAuthorizedUsers(address(swapInterface), address(joe)));
    }

    // ~ addWalletToWhitelist() Testing ~

    // addWalletToWhitelist state changes.
    function test_swapInterface_swapInterface_addWalletToWhitelist_state_changes() public {
        //Pre state
        assert(!swapInterface.whitelistedWallet(address(joe)));

        //State change
        assert(dev.try_addWalletToWhitelist(address(swapInterface), address(joe)));

        //Post state
        assert(swapInterface.whitelistedWallet(address(joe)));

    }

    // addWalletToWhitelist restrictions.
    function test_swapInterface_addWalletToWhitelist_restrictions() public {
        // "joe" should not be able to call addWalletToWhitelist().
        assert(!joe.try_addWalletToWhitelist(address(swapInterface), address(joe)));

        // "bob" should not be able to call addWalletToWhitelist().
        assert(!bob.try_addWalletToWhitelist(address(swapInterface), address(joe)));

        // "val" should be able to call addWalletToWhitelist().
        assert(val.try_addWalletToWhitelist(address(swapInterface), address(joe)));

        // "dev" should be able to call addWalletToWhitelist().
        dev.try_removeWalletFromWhitelist(address(swapInterface), address(joe));    // NOTE: joe must be removed again or add won't function properly.
        assert(dev.try_addWalletToWhitelist(address(swapInterface), address(joe)));


        // should not be able to add wallets that have already been added.
        assert(!dev.try_addWalletToWhitelist(address(swapInterface), address(joe)));

    }

    // ~ removeWalletFromWhitelist() Testing ~

    // removeWalletFromWhitelist state changes.
    function test_swapInterface_removeWalletFromWhitelist_state_changes() public {
        // pre-state
        assert(swapInterface.whitelistedWallet(address(bob)));

        // state change
        assert(dev.try_removeWalletFromWhitelist(address(swapInterface), address(bob)));

        // post-state
        assert(!swapInterface.whitelistedWallet(address(bob)));
    }

    // removeWalletFromWhitelist restrictions.
    function test_swapInterface_removeWalletFromWhitelist_restrictions() public {
        // setup: add joe to whitelist.
        dev.try_addWalletToWhitelist(address(swapInterface), address(joe));


        // "joe" should not be able to call removeWalletFromWhitelist().
        assert(!joe.try_removeWalletFromWhitelist(address(swapInterface), address(joe)));

        // "bob" should not be able to call removeWalletFromWhitelist().
        assert(!bob.try_removeWalletFromWhitelist(address(swapInterface), address(joe)));

        // "val" should be able to call removeWalletFromWhitelist().
        assert(val.try_removeWalletFromWhitelist(address(swapInterface), address(joe)));

        // "dev" should be able to call removeWalletFromWhitelist().
        dev.try_addWalletToWhitelist(address(swapInterface), address(joe));     // NOTE: joe must be added again or the remove will not function properly.
        assert(dev.try_removeWalletFromWhitelist(address(swapInterface), address(joe)));


        // should not be able to remove addresses that have already been removed.
        assert(!dev.try_removeWalletFromWhitelist(address(swapInterface), address(joe)));
    }

    // ~ changeStableCurrency() Testing ~

    // change stable currency state changes.
    function test_swapInterface_changeStableCurrency_state_changes() public {
        // pre-state
        assertEq(swapInterface.stableCurrency(), USDC);

        // state change
        assert(dev.try_changeStableCurrency(address(swapInterface), USDT));

        // post-state
        assertEq(swapInterface.stableCurrency(), USDT);
    }

    // change stable currency restrictions.
    function test_swapInterface_changeStableCurrency_restrictions() public {
        // "joe" should not be able to call changeStableCurrency().
        assert(!joe.try_changeStableCurrency(address(swapInterface), USDT));

        // "bob" should not be able to call changeStableCurrency().
        assert(!bob.try_changeStableCurrency(address(swapInterface), USDT));

        // "val" should not be able to call changeStableCurrency().
        assert(!val.try_changeStableCurrency(address(swapInterface), USDT));

        // "dev" should be able to call changeStableCurrency().
        assert(dev.try_changeStableCurrency(address(swapInterface), USDT));
    }

    // ~ enableContract() Testing ~

    // enable contract state changes.
    function test_swapInterface_enableContract_state_changes() public {
        dev.try_disableContract(address(swapInterface));

        // pre-state
        assertTrue(!swapInterface.contractEnabled());

        // state change
        assert(dev.try_enableContract(address(swapInterface)));

        // post-state
        assertTrue(swapInterface.contractEnabled());
    }

    // enable contract restrictions
    function test_swapInterface_enableContract_restrictions() public {
        dev.try_disableContract(address(swapInterface));

        // "joe" should not be able to call enableContract().
        assert(!joe.try_enableContract(address(swapInterface)));

        // "bob" should not be able to call enableContract().
        assert(!bob.try_enableContract(address(swapInterface)));

        // "val" should not be able to call enableContract().
        assert(!val.try_enableContract(address(swapInterface)));

        // "dev" should be able to call enableContract().
        assert(dev.try_enableContract(address(swapInterface)));

    }

    // ~ disableContract() Testing ~

    // disable contract state changes.
    function test_swapInterface_disableContract_state_changes() public {

        // pre-state
        assertTrue(swapInterface.contractEnabled());

        // state change
        assert(dev.try_disableContract(address(swapInterface)));

        // post-state
        assertTrue(!swapInterface.contractEnabled());
    }

    // disable contract restrictions.
    function test_swapInterface_disableContract_restrictions() public {
        // "joe" should not be able to call disableContract().
        assert(!joe.try_disableContract(address(swapInterface)));

        // "bob" should not be able to call disableContract().
        assert(!bob.try_disableContract(address(swapInterface)));

        // "val" should not be able to call disableContract().
        assert(!val.try_disableContract(address(swapInterface)));

        // "dev" should be able to call disableContract().
        assert(dev.try_disableContract(address(swapInterface)));

    }

    // ~ updateTokenWhitelist() Testing ~

    // update token whitelist state changes.
    function test_swapInterface_updateTokenWhitelist_state_changes() public {
        // pre-state
        assert(!swapInterface.whitelistedToken(DAI));

        // state change 1 (allow DAI for token whitelist)
        assert(dev.try_updateTokenWhitelist(address(swapInterface), DAI, true));

        // post-state
        assert(swapInterface.whitelistedToken(DAI));

        // state change 2 (disallow DAI from token whitelist)
        assert(dev.try_updateTokenWhitelist(address(swapInterface), DAI, false));

        // post state 2
        assert(!swapInterface.whitelistedToken(DAI));
    }

    // update token whitelist restrictions.
    function test_swapInterface_updateTokenWhitelist_restrictions() public {
        // "joe" should not be able to call updateTokenWhitelist().
        assert(!joe.try_updateTokenWhitelist(address(swapInterface), DAI, true));

        // "bob" should not be able to call updateTokenWhitelist().
        assert(!bob.try_updateTokenWhitelist(address(swapInterface), DAI, true));

        // "val" should not be able to call updateTokenWhitelist().
        assert(!val.try_updateTokenWhitelist(address(swapInterface), DAI, true));

        // "dev" should be able to call updateTokenWhitelist().
        assert(dev.try_updateTokenWhitelist(address(swapInterface), DAI, true));


        // should not be able to make redundant calls.
        assert(!dev.try_updateTokenWhitelist(address(swapInterface), DAI, true));
    }

    // ~ updateTreasury() testing ~

    function test_swapInterface_updateTreasury_state_change() public {
        // pre-state
        // treasury is the expected address.
        assertEq(swapInterface.Treasury(), address(treasury));

        // state change
        // owner changes the address to a new one.
        assert(dev.try_updateTreasury(address(swapInterface), address(2)));

        // post-state
        // treasury is the new address.
        assertEq(swapInterface.Treasury(), address(2));
    }

    function test_swapInterface_updateTreasury_restrictions() public {
        // "joe" should not be able to call updateTreasury().
        assert(!joe.try_updateTreasury(address(swapInterface), address(2)));

        // "bob" should not be able to call updateTreasury().
        assert(!bob.try_updateTreasury(address(swapInterface), address(2)));

        // "val" should not be able to call updateTreasury().
        assert(!val.try_updateTreasury(address(swapInterface), address(2)));

        // "dev" should be able to call updateTreasury().
        assert(dev.try_updateTreasury(address(swapInterface), address(2)));


        // should not be able to set as address 0.
        assert(!dev.try_updateTreasury(address(swapInterface), address(0)));

        // should not be able to set treasury to the same address.
        assert(!dev.try_updateTreasury(address(swapInterface), address(2)));
    }

    // ~ Invest/Swap Testing ~

    // NOTE: Must call swapInterface::swap() through try_invest since its an internal function.
    function test_swapInterface_invest_state_change_DAI() public {

        // ----------
        // DAI swap()
        // ----------
        uint256 swapAmount = 1000 ether;

        // Allow DAI to be swapped setup.
        dev.try_updateTokenWhitelist(address(swapInterface), DAI, true);
        mint("DAI", address(bob), swapAmount);

        // pre-state (no USDC)
        // verifies pre-state balances of USDC and DAI.
        assertEq(IERC20(USDC).balanceOf(swapInterface.Treasury()), 0 * USD);
        assertEq(IERC20(DAI).balanceOf(address(bob)), swapAmount);

        assertEq(treasury.getInvestorData(address(bob)).totalAmountInvested, 0);
        assertEq(treasury.getInvestmentLibrary(address(bob)).length, 0);
        assertEq(treasury.getDividendLibrary(address(bob)).length, 0);
        assertEq(IERC20(address(bloomToken)).totalSupply(), 0);
        assertEq(IERC20(address(bloomToken)).balanceOf(address(bob)), 0);

        // state change -
        // calling invest() to execute the swap from DAI to USDC.
        assert(bob.try_approveToken(DAI, address(swapInterface), swapAmount));
        assert(bob.try_invest(address(swapInterface), DAI, swapAmount));

        // post-state (swapped to USDC)
        // verifies post-state balance of USDC.

        uint256 amountReceived = IERC20(USDC).balanceOf(swapInterface.Treasury());

        assertEq(treasury.getInvestorData(address(bob)).totalAmountInvested, amountReceived);
        assertEq(treasury.getInvestmentLibrary(address(bob)).length, 1);
        assertEq(treasury.getDividendLibrary(address(bob)).length, 0);

        assertEq(treasury.getInvestmentLibrary(address(bob))[0].amountInvested, amountReceived);
        assertEq(treasury.getInvestmentLibrary(address(bob))[0].timeUnix, block.timestamp);

        assertEq(IERC20(address(bloomToken)).totalSupply(), amountReceived * 10**12);
        assertEq(IERC20(address(bloomToken)).balanceOf(address(bob)), amountReceived * 10**12);
    }

    function test_swapInterface_invest_state_change_USDT() public {

        // ----------
        // USDT swap()
        // ----------
        uint256 swapAmount = 1000 * USD;

        // Allow USDT to be swapped setup.
        dev.try_updateTokenWhitelist(address(swapInterface), USDT, true);
        mint("USDT", address(bob), swapAmount);

        // pre-state (no USDC)
        // verifies pre-state balances of USDC and USDT.
        assertEq(IERC20(USDC).balanceOf(swapInterface.Treasury()), 0 * USD);
        assertEq(IERC20(USDT).balanceOf(address(bob)), swapAmount);

        assertEq(treasury.getInvestorData(address(bob)).totalAmountInvested, 0);
        assertEq(treasury.getInvestmentLibrary(address(bob)).length, 0);
        assertEq(treasury.getDividendLibrary(address(bob)).length, 0);
        assertEq(IERC20(address(bloomToken)).totalSupply(), 0);
        assertEq(IERC20(address(bloomToken)).balanceOf(address(bob)), 0);

        // state change -
        // calling invest() to execute the swap from USDT to USDC.
        assert(bob.try_approveToken(USDT, address(swapInterface), swapAmount));
        assert(bob.try_invest(address(swapInterface), USDT, swapAmount));

        // post-state (swapped to USDC)
        // verifies post-state balances of USDC and USDT.
        uint256 amountReceived = IERC20(USDC).balanceOf(swapInterface.Treasury());

        assertEq(treasury.getInvestorData(address(bob)).totalAmountInvested, amountReceived);
        assertEq(treasury.getInvestmentLibrary(address(bob)).length, 1);
        assertEq(treasury.getDividendLibrary(address(bob)).length, 0);

        assertEq(treasury.getInvestmentLibrary(address(bob))[0].amountInvested, amountReceived);
        assertEq(treasury.getInvestmentLibrary(address(bob))[0].timeUnix, block.timestamp);

        assertEq(IERC20(address(bloomToken)).totalSupply(), amountReceived * 10**12);
        assertEq(IERC20(address(bloomToken)).balanceOf(address(bob)), amountReceived * 10**12);
    }

    function test_swapInterface_invest_state_change_FRAX() public {

        // ----------
        // FRAX swap()
        // ----------
        uint256 swapAmount = 1000 ether;

        // Allow FRAX to be swapped setup.
        dev.try_updateTokenWhitelist(address(swapInterface), FRAX, true);
        mint("FRAX", address(bob), swapAmount);

        // pre-state (no USDC)
        // verifies pre-state balances of USDC and FRAX.
        assertEq(IERC20(USDC).balanceOf(swapInterface.Treasury()), 0 * USD);
        assertEq(IERC20(FRAX).balanceOf(address(bob)), swapAmount);

        assertEq(treasury.getInvestorData(address(bob)).totalAmountInvested, 0);
        assertEq(treasury.getInvestmentLibrary(address(bob)).length, 0);
        assertEq(treasury.getDividendLibrary(address(bob)).length, 0);
        assertEq(IERC20(address(bloomToken)).totalSupply(), 0);
        assertEq(IERC20(address(bloomToken)).balanceOf(address(bob)), 0);

        // state change -
        // calling invest() to execute the swap from FRAX to USDC.
        assert(bob.try_approveToken(FRAX, address(swapInterface), swapAmount));
        assert(bob.try_invest(address(swapInterface), FRAX, swapAmount));

        // post-state (swapped to USDC)
        // verifies post-state balances of USDC and FRAX.
        uint256 amountReceived = IERC20(USDC).balanceOf(swapInterface.Treasury());

        assertEq(treasury.getInvestorData(address(bob)).totalAmountInvested, amountReceived);
        assertEq(treasury.getInvestmentLibrary(address(bob)).length, 1);
        assertEq(treasury.getDividendLibrary(address(bob)).length, 0);

        assertEq(treasury.getInvestmentLibrary(address(bob))[0].amountInvested, amountReceived);
        assertEq(treasury.getInvestmentLibrary(address(bob))[0].timeUnix, block.timestamp);

        assertEq(IERC20(address(bloomToken)).totalSupply(), amountReceived * 10**12);
        assertEq(IERC20(address(bloomToken)).balanceOf(address(bob)), amountReceived * 10**12);
    }

    function test_swapInterface_invest_state_change_WETH() public {

        // ----------
        // WETH swap()
        // ----------
        uint256 swapAmount = 10 ether;

        // Allow WETH to be swapped setup.
        dev.try_updateTokenWhitelist(address(swapInterface), WETH, true);
        mint("WETH", address(bob), swapAmount);

        // pre-state (no USDC)
        // verifies pre-state balances of USDC and WETH.
        assertEq(IERC20(USDC).balanceOf(swapInterface.Treasury()), 0 * USD);
        assertEq(IERC20(WETH).balanceOf(address(bob)), swapAmount);

        assertEq(treasury.getInvestorData(address(bob)).totalAmountInvested, 0);
        assertEq(treasury.getInvestmentLibrary(address(bob)).length, 0);
        assertEq(treasury.getDividendLibrary(address(bob)).length, 0);
        assertEq(IERC20(address(bloomToken)).totalSupply(), 0);
        assertEq(IERC20(address(bloomToken)).balanceOf(address(bob)), 0);

        // state change -
        // calling invest() to execute the swap from WETH to USDC.
        assert(bob.try_approveToken(WETH, address(swapInterface), swapAmount));
        assert(bob.try_invest(address(swapInterface), WETH, swapAmount));

        // post-state (swapped to USDC)
        // verifies post-state balances of USDC and WETH.
        uint256 amountReceived = IERC20(USDC).balanceOf(swapInterface.Treasury());

        assertEq(treasury.getInvestorData(address(bob)).totalAmountInvested, amountReceived);
        assertEq(treasury.getInvestmentLibrary(address(bob)).length, 1);
        assertEq(treasury.getDividendLibrary(address(bob)).length, 0);

        assertEq(treasury.getInvestmentLibrary(address(bob))[0].amountInvested, amountReceived);
        assertEq(treasury.getInvestmentLibrary(address(bob))[0].timeUnix, block.timestamp);

        assertEq(IERC20(address(bloomToken)).totalSupply(), amountReceived * 10**12);
        assertEq(IERC20(address(bloomToken)).balanceOf(address(bob)), amountReceived * 10**12);

    }

    function test_swapInterface_invest_state_change_WBTC() public {

        // ----------
        // WBTC swap()
        // ----------
        uint256 swapAmount = 10 * BTC;

        // Allow WBTC to be swapped setup.
        dev.try_updateTokenWhitelist(address(swapInterface), WBTC, true);
        mint("WBTC", address(bob), swapAmount);

        // pre-state (no USDC)
        // verifies pre-state balances of USDC and WBTC.
        assertEq(IERC20(USDC).balanceOf(swapInterface.Treasury()), 0 * USD);
        assertEq(IERC20(WBTC).balanceOf(address(bob)), swapAmount);

        assertEq(treasury.getInvestorData(address(bob)).totalAmountInvested, 0);
        assertEq(treasury.getInvestmentLibrary(address(bob)).length, 0);
        assertEq(treasury.getDividendLibrary(address(bob)).length, 0);
        assertEq(IERC20(address(bloomToken)).totalSupply(), 0);
        assertEq(IERC20(address(bloomToken)).balanceOf(address(bob)), 0);

        // state change -
        // calling invest() to execute the swap from WBTC to USDC.
        assert(bob.try_approveToken(WBTC, address(swapInterface), swapAmount));
        assert(bob.try_invest(address(swapInterface), WBTC, swapAmount));

        // post-state (swapped to USDC)
        // verifies post-state balances of USDC and WBTC.
        uint256 amountReceived = IERC20(USDC).balanceOf(swapInterface.Treasury());

        assertEq(treasury.getInvestorData(address(bob)).totalAmountInvested, amountReceived);
        assertEq(treasury.getInvestmentLibrary(address(bob)).length, 1);
        assertEq(treasury.getDividendLibrary(address(bob)).length, 0);

        assertEq(treasury.getInvestmentLibrary(address(bob))[0].amountInvested, amountReceived);
        assertEq(treasury.getInvestmentLibrary(address(bob))[0].timeUnix, block.timestamp);

        assertEq(IERC20(address(bloomToken)).totalSupply(), amountReceived * 10**12);
        assertEq(IERC20(address(bloomToken)).balanceOf(address(bob)), amountReceived * 10**12);
    }

    function test_swapInterface_investETH_state_change() public {
        
        // ----------
        // WBTC swap()
        // ----------

        // Allow WETH to be swapped setup.
        dev.try_updateTokenWhitelist(address(swapInterface), WETH, true);

        // pre-state (no USDC)
        // verifies pre-state balances of USDC and WETH.
        assertEq(IERC20(USDC).balanceOf(swapInterface.Treasury()), 0 * USD);

        assertEq(treasury.getInvestorData(address(bob)).totalAmountInvested, 0);
        assertEq(treasury.getInvestmentLibrary(address(bob)).length, 0);
        assertEq(treasury.getDividendLibrary(address(bob)).length, 0);
        assertEq(IERC20(address(bloomToken)).totalSupply(), 0);
        assertEq(IERC20(address(bloomToken)).balanceOf(address(bob)), 0);

        // state change -
        // calling invest_ETH() to execute swap chain from ETH to USDC.
        assert(bob.try_investETH{value: 10 ether}(address(swapInterface)));

        // post-state (swapped to USDC)
        // verifies post-state balances of USDC and WBTC.
        uint256 amountReceived = IERC20(USDC).balanceOf(swapInterface.Treasury());

        assertEq(treasury.getInvestorData(address(bob)).totalAmountInvested, amountReceived);
        assertEq(treasury.getInvestmentLibrary(address(bob)).length, 1);
        assertEq(treasury.getDividendLibrary(address(bob)).length, 0);

        assertEq(treasury.getInvestmentLibrary(address(bob))[0].amountInvested, amountReceived);
        assertEq(treasury.getInvestmentLibrary(address(bob))[0].timeUnix, block.timestamp);

        assertEq(IERC20(address(bloomToken)).totalSupply(), amountReceived * 10**12);
        assertEq(IERC20(address(bloomToken)).balanceOf(address(bob)), amountReceived * 10**12);
    }

    // ~ invest() and investETH() restrictions ~

    function try_swapInterface_invest_restrictions() public {

        // Allow DAI to be swapped setup.
        dev.try_updateTokenWhitelist(address(swapInterface), DAI, true);

        // "joe" should not be able to call invest().
        assert(!joe.try_invest(address(swapInterface), DAI, 10 ether));

        // "bob" should be able to call invest().
        assert(bob.try_invest(address(swapInterface), DAI, 10 ether));

        // "val" should not be able to call invest().
        assert(!val.try_invest(address(swapInterface), DAI, 10 ether));

        // "dev" should not be able to call invest().
        assert(!dev.try_invest(address(swapInterface), DAI, 10 ether));


        // should not be able to invest 0.
        assert(bob.try_invest(address(swapInterface), DAI, 0 ether));

        // should not be able to invest tokens that are not whitelisted.
        assert(bob.try_invest(address(swapInterface), WBTC, 10 * BTC));

        // TEMP: what happens if we try to invest 1?
        assert(bob.try_invest(address(swapInterface), DAI, 1 ether));
    }

    function try_swapInterface_investETH_restrictions() public {
        // "joe" should not be able to call investETH().
        assert(!joe.try_investETH{value: 10 ether}(address(swapInterface)));

        // "bob" should be able to call investETH().
        assert(bob.try_investETH{value: 10 ether}(address(swapInterface)));

        // "val" should not be able to call investETH().
        assert(!val.try_investETH{value: 10 ether}(address(swapInterface)));

        // "dev" should not be able to call investETH().
        assert(!dev.try_investETH{value: 10 ether}(address(swapInterface)));

        
        // should not be able to invest 0.
        assert(bob.try_investETH{value: 0 ether}(address(swapInterface)));

        // TEMP: what happens if we try to invest 1?
        assert(bob.try_investETH{value: 1 ether}(address(swapInterface)));
    }

}
