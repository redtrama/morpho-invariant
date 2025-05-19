// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {Properties} from "./Properties.sol";
import {vm} from "@chimera/Hevm.sol";

// Helpers
import {Panic} from "@recon/Panic.sol";
import {MockERC20} from "@recon/MockERC20.sol";
import {MarketParams, Position, Authorization, Signature} from "src/interfaces/IMorpho.sol";

abstract contract TargetFunctions is BaseTargetFunctions, Properties {
    function morpho_accrueInterest(MarketParams memory marketParams) public updateGhosts asActor {
        morpho.accrueInterest(marketParams);
    }

    function morpho_borrow(
        MarketParams memory marketParams,
        uint256 assets,
        uint256 shares,
        address onBehalf,
        address receiver
    ) public updateGhosts asActor {
        morpho.borrow(marketParams, assets, shares, onBehalf, receiver);
    }

    function morpho_createMarket(MarketParams memory marketParams) public updateGhosts asActor {
        morpho.createMarket(marketParams);
    }

    function morpho_enableIrm(address irm) public updateGhosts asActor {
        morpho.enableIrm(irm);
    }

    function morpho_enableLltv(uint256 lltv) public updateGhosts asActor {
        morpho.enableLltv(lltv);
    }

    function morpho_flashLoan(address token, uint256 assets, bytes memory data) public updateGhosts asActor {
        morpho.flashLoan(token, assets, data);
    }

    function morpho_liquidate(
        MarketParams memory marketParams,
        address borrower,
        uint256 seizedAssets,
        uint256 repaidShares,
        bytes memory data
    ) public updateGhosts asActor {
        morpho.liquidate(marketParams, borrower, seizedAssets, repaidShares, data);
    }

    function morpho_repay(
        MarketParams memory marketParams,
        uint256 assets,
        uint256 shares,
        address onBehalf,
        bytes memory data
    ) public updateGhosts asActor {
        morpho.repay(marketParams, assets, shares, onBehalf, data);
    }

    function morpho_setAuthorization(address authorized, bool newIsAuthorized) public updateGhosts asActor {
        morpho.setAuthorization(authorized, newIsAuthorized);
    }

    function morpho_setAuthorizationWithSig(Authorization memory authorization, Signature memory signature)
        public
        updateGhosts
        asActor
    {
        morpho.setAuthorizationWithSig(authorization, signature);
    }

    function morpho_setFee(MarketParams memory marketParams, uint256 newFee) public updateGhosts asActor {
        morpho.setFee(marketParams, newFee);
    }

    function morpho_setFeeRecipient(address newFeeRecipient) public updateGhosts asActor {
        morpho.setFeeRecipient(newFeeRecipient);
    }

    function morpho_setOwner(address newOwner) public updateGhosts asActor {
        morpho.setOwner(newOwner);
    }

    function morpho_supply(
        MarketParams memory marketParams,
        uint256 assets,
        uint256 shares,
        address onBehalf,
        bytes memory data
    ) public updateGhosts asActor {
        morpho.supply(marketParams, assets, shares, onBehalf, data);
    }

    function morpho_supplyCollateral(
        MarketParams memory marketParams,
        uint256 assets,
        address onBehalf,
        bytes memory data
    ) public updateGhosts asActor {
        morpho.supplyCollateral(marketParams, assets, onBehalf, data);
    }

    function morpho_withdraw(
        MarketParams memory marketParams,
        uint256 assets,
        uint256 shares,
        address onBehalf,
        address receiver
    ) public updateGhosts asActor {
        morpho.withdraw(marketParams, assets, shares, onBehalf, receiver);
    }

    function morpho_withdrawCollateral(
        MarketParams memory marketParams,
        uint256 assets,
        address onBehalf,
        address receiver
    ) public updateGhosts asActor {
        morpho.withdrawCollateral(marketParams, assets, onBehalf, receiver);
    }

    /// === Managers Targets === ///
    // == ACTOR HANDLERS == //

    /// @dev Start acting as another actor
    function switchActor(uint256 entropy) public {
        _switchActor(entropy);
    }

    /// @dev Starts using a new asset
    function switch_asset(uint256 entropy) public {
        _switchAsset(entropy);
    }

    /// @dev Deploy a new token and add it to the list of assets, then set it as the current asset
    function add_new_asset(uint8 decimals) public returns (address) {
        address newAsset = _newAsset(decimals);
        return newAsset;
    }

    /// === GHOST UPDATING HANDLERS ===///
    /// We `updateGhosts` cause you never know (e.g. donations)
    /// If you don't want to track donations, remove the `updateGhosts`

    /// @dev Approve to arbitrary address, uses Actor by default
    /// NOTE: You're almost always better off setting approvals in `Setup`
    function asset_approve(address to, uint128 amt) public updateGhosts asActor {
        MockERC20(_getAsset()).approve(to, amt);
    }

    /// @dev Mint to arbitrary address, uses owner by default, even though MockERC20 doesn't check
    function asset_mint(address to, uint128 amt) public updateGhosts asAdmin {
        MockERC20(_getAsset()).mint(to, amt);
    }
}
