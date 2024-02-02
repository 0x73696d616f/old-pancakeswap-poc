// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2 as console} from "forge-std/Test.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IPancakeSwap {
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);
}

contract OldTest is Test {

    function setUp() public {
        vm.createSelectFork("https://rpc.linea.build", 2015733);
    }

    function test_old() public {
        IPancakeSwap pancakeSwap_ = IPancakeSwap(0xE817A59F8A030544Ff65F47536abA272F6d63059);

        pancakeSwap_.swap(address(this), true, 1e18, 2595161904538294762334659607, "");

        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = 4;
        secondsAgos[1] = 0;
        vm.expectRevert(bytes("OLD"));
        pancakeSwap_.observe(secondsAgos);
    }

    function pancakeV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata
    ) external {
        uint256 prevBalance0_ = IERC20(0x0D1E753a25eBda689453309112904807625bEFBe).balanceOf(msg.sender);
        uint256 prevBalance1_ = IERC20(0xe5D7C2a44FfDDf6b295A15c148167daaAf5Cf34f).balanceOf(msg.sender);

        if (amount0Delta > 0) deal(0x0D1E753a25eBda689453309112904807625bEFBe, msg.sender, prevBalance0_ + uint256(amount0Delta));
        if (amount1Delta > 0) deal(0xe5D7C2a44FfDDf6b295A15c148167daaAf5Cf34f, msg.sender, prevBalance1_ + uint256(amount1Delta));
    }
}
