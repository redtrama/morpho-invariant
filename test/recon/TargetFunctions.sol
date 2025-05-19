// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {Properties} from "./Properties.sol";
import {vm} from "@chimera/Hevm.sol";

// Helpers
import {Panic} from "@recon/Panic.sol";
import {MockERC20} from "@recon/MockERC20.sol";
import {MarketParams, Position, Authorization, Signature} from "src/interfaces/IMorpho.sol";

import {MarketParamsLib} from "src/libraries/MarketParamsLib.sol";

abstract contract TargetFunctions is BaseTargetFunctions, Properties {
    /// Clamped Handlers ///
    /// We just pass assets to the function
    function morpho_clamped_supply_asset(uint256 assets) public {
        morpho_supply(assets, 0, address(this), hex"");
    }

    function morpho_clamped_supply_collateral(uint256 assets) public {
        morpho_supplyCollateral(assets, address(this), hex"");
    }

    function morpho_liquidate_clamped_assets(uint256 assets) public {
        morpho_liquidate(address(this), assets, 0, hex"");
    }

    function morpho_liquidate_clamped_shares(uint256 shares) public {
        morpho_liquidate(address(this), 0, shares, hex"");
    }
   
    // @dev to match the specific path where it liquidates for exact borrowShares amount
    // we should get that specific position and liquidate for that amount
    function shortcut_liquidate_all_positions() public {
        // We get the borrowShares for the position
        (,uint256 sizedShares ,) = morpho.position(MarketParamsLib.id(marketParams), address(this));
        // liquidate for that exact amount
        morpho_liquidate(address(this), 0, sizedShares, hex"");
    }
    
    function morpho_repay_clamped_assets(uint256 assets) public {
        morpho_repay(assets, 0, address(this), hex"");
    }

    /// Automatic Handlers ///
    function oracle_setPrice(uint256 newPrice) public {
        oracle.setPrice(newPrice);
    }

    function morpho_accrueInterest() public {
        morpho.accrueInterest(marketParams);
    }

    function morpho_borrow(uint256 assets, uint256 shares, address onBehalf, address receiver)
        public
    {
        morpho.borrow(marketParams, assets, shares, onBehalf, receiver);
    }

    function morpho_createMarket() public {
        morpho.createMarket(marketParams);
    }

    function morpho_enableIrm(address irm) public  {
        morpho.enableIrm(irm);
    }

    function morpho_enableLltv(uint256 lltv) public  {
        morpho.enableLltv(lltv);
    }

    function morpho_flashLoan(address token, uint256 assets, bytes memory data) public {
        morpho.flashLoan(token, assets, data);
    }

    function morpho_liquidate(address borrower, uint256 seizedAssets, uint256 repaidShares, bytes memory data)
        public
    {
        morpho.liquidate(marketParams, borrower, seizedAssets, repaidShares, data);
        // This is declared on Setup and checked on CryticToFoundry
        // hasLiquidated = true;
    }

    function morpho_repay(uint256 assets, uint256 shares, address onBehalf, bytes memory data)
        public
    {
        morpho.repay(marketParams, assets, shares, onBehalf, data);
        // hasRepaid canary is set on Setup
        // hasRepaid = true;
    }

    function morpho_setAuthorization(address authorized, bool newIsAuthorized) public {
        morpho.setAuthorization(authorized, newIsAuthorized);
    }

    function morpho_setAuthorizationWithSig(Authorization memory authorization, Signature memory signature)
        public
    {
        morpho.setAuthorizationWithSig(authorization, signature);
    }

    function morpho_setFee(uint256 newFee) public {
        morpho.setFee(marketParams, newFee);
    }

    function morpho_setFeeRecipient(address newFeeRecipient) public {
        morpho.setFeeRecipient(newFeeRecipient);
    }

    function morpho_setOwner(address newOwner) public {
        morpho.setOwner(newOwner);
    }

    function morpho_supply(uint256 assets, uint256 shares, address onBehalf, bytes memory data)
        public
    {
        morpho.supply(marketParams, assets, shares, onBehalf, data);
    }

    function morpho_supplyCollateral(uint256 assets, address onBehalf, bytes memory data) public {
        morpho.supplyCollateral(marketParams, assets, onBehalf, data);
    }

    function morpho_withdraw(uint256 assets, uint256 shares, address onBehalf, address receiver)
        public
    {
        morpho.withdraw(marketParams, assets, shares, onBehalf, receiver);
    }

    function morpho_withdrawCollateral(uint256 assets, address onBehalf, address receiver)
        public
    {
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
