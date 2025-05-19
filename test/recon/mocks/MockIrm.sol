// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {MarketParams, Position, Authorization, Signature, Market} from "src/interfaces/IMorpho.sol";

contract MockIrm {
    uint256 _borrowRate;

    function setNewBorrowRate(uint256 newBorrowRate) external {
        _borrowRate = newBorrowRate;
    }

    function borrowRate(MarketParams memory marketParams, Market memory market) external view returns (uint256) {
        return _borrowRate;
    }
}
