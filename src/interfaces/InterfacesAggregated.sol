// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function mint(address account, uint256 amount) external;
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function getAmountsOut(
        uint amountIn, 
        address[] calldata path
    ) external view returns (uint[] memory amounts);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IWETH {
    function deposit() external payable;
    function withdraw(uint) external;
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint value) external returns (bool);
}

interface ITreasury {
    function updateStableReceived(address _wallet, uint _amount, uint _timeUnix) external;
}


// DAI, USDC, USDT
interface curve3PoolStableSwap {
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external;
}

// FRAX, USDT
interface curveFraxUSDCStableSwap {
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external; //TODO: is this correct?
}

// USDT, WBTC, WETH
interface curveTriCrypto2StableSwap {
    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external; //TODO: is this correct?
}