// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {FoundryAsserts} from "@chimera/FoundryAsserts.sol";

import "forge-std/console2.sol";

import {Test} from "forge-std/Test.sol";
import {TargetFunctions} from "./TargetFunctions.sol";

// forge test --match-contract CryticToFoundry -vv
contract CryticToFoundry is Test, TargetFunctions, FoundryAsserts {
    function setUp() public {
        setup();
    }

    // forge test --match-test test_crytic -vvv
    function test_crytic() public {
        // Here we can test functions from TargetFunctions
        // morpho_supply comes from there.
        // Try to supply 1e18 assets and collateral
        morpho_clamped_supply_asset(1e18);
        morpho_clamped_supply_collateral(1e18);

        oracle.setPrice(1e30);
        // try to borrow less than we supplied just to be sure that the function works
        morpho_borrow(1e6, 0, address(this), address(this));

        // to Liquidate
        // Set the price to zero
        // oracle_setPrice(0);

        // // Liquidate
        // morpho_liquidate(address(this) , 1e6 , 0, hex"");

morpho_repay(1e6, 0, address(this), hex"");



    }
}
