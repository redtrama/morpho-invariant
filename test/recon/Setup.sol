// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

// Chimera deps
import {BaseSetup} from "@chimera/BaseSetup.sol";
import {vm} from "@chimera/Hevm.sol";

// Managers
import {ActorManager} from "@recon/ActorManager.sol";
import {AssetManager} from "@recon/AssetManager.sol";

// Helpers
import {Utils} from "@recon/Utils.sol";

// Your deps
import "src/Morpho.sol";
import {OracleMock} from "src/mocks/OracleMock.sol";
import {ERC20Mock} from "src/mocks/ERC20Mock.sol";
import {MockIrm} from "test/recon/mocks/MockIrm.sol";

import {MarketParams, Position, Authorization, Signature} from "src/interfaces/IMorpho.sol";

abstract contract Setup is BaseSetup, ActorManager, AssetManager, Utils {
    Morpho morpho;

    // Mocks
    OracleMock oracle;
    MockIrm irm;
    ERC20Mock asset;
    ERC20Mock liability;

    // Struct
    MarketParams marketParams;

    // Canaries
    bool hasRepaid;
    bool hasLiquidated;

    /// === Setup === ///
    /// This contains all calls to be performed in the tester constructor, both for Echidna and Foundry
    function setup() internal virtual override {
        // We setup address(this) as the owner of the contract
        morpho = new Morpho(address(this)); // TODO: Add parameters here

        // Deploy Mocks
        oracle = new OracleMock();
        irm = new MockIrm();
        asset = new ERC20Mock();
        liability = new ERC20Mock();

        // Create a market
        // @dev go to the function and see the requires for creating a market
        // @dev we will see there that IRM and LTVL need to be enabled
        morpho.enableIrm(address(irm));
        morpho.enableLltv(8e17); // This can be dynamic

        marketParams = MarketParams({
            loanToken: address(liability),
            collateralToken: address(asset),
            oracle: address(oracle),
            irm: address(irm),
            lltv: 8e17
        });

        morpho.createMarket(marketParams);

        /// Set balance to address(this) (the fuzzer) to have balance of the mock tokens
        liability.setBalance(address(this), type(uint88).max);
        asset.setBalance(address(this), type(uint88).max);

        /// Approve to the morpho contract to have unlimited allowance
        liability.approve(address(morpho), type(uint256).max);
        asset.approve(address(morpho), type(uint256).max);
    }

    /// === MODIFIERS === ///
    /// Prank admin and actor
    modifier asAdmin() {
        vm.prank(address(this));
        _;
    }

    modifier asActor() {
        vm.prank(address(_getActor()));
        _;
    }
}
