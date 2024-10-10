// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../src/interface/IProtocol.sol";

contract MockProtocol is IProtocol {
    uint96 public nextRequestId;
    Request[] private requests;
    mapping(uint96 => mapping(address => uint256)) private collateralMapping;

    function createRequest(
        address _loanAddress,
        uint256 _amount,
        uint16 _interest,
        uint256 _totalRepayment,
        uint256 _returnDate,
        Status _status,
        address[] memory _collateralTokens,
        uint256[] memory _collateralAmounts
    ) public {
        Request memory newRequest = Request({
            requestId: nextRequestId,
            author: msg.sender,
            amount: _amount,
            interest: _interest,
            totalRepayment: _totalRepayment,
            returnDate: _returnDate,
            lender: address(0),
            loanRequestAddr: _loanAddress,
            collateralTokens: _collateralTokens,
            status: _status
        });

        for (uint256 i = 0; i < _collateralTokens.length; i++) {
            collateralMapping[nextRequestId][
                _collateralTokens[i]
            ] = _collateralAmounts[i];
        }

        requests.push(newRequest);
        nextRequestId++;
    }

    function getHealthFactor(
        address _user
    ) external view override returns (uint8) {
        // Returning a mock value for health factor
        return 100;
    }

    function getAllRequest() external view override returns (Request[] memory) {
        return requests;
    }

    function liquidateUserRequest(uint96 requestId) external override {
        for (uint256 i = 0; i < requests.length; i++) {
            if (requests[i].requestId == requestId) {
                requests[i].status = Status.CLOSED;
                break;
            }
        }
    }

    function getRequestToColateral(
        uint96 _requestId,
        address _token
    ) external view override returns (uint256) {
        return collateralMapping[_requestId][_token];
    }

    function getUsdValue(
        address _token,
        uint256 _amount,
        uint8 _decimal
    ) external view override returns (uint256) {
        // Returning a mock value for the USD equivalent of collateral
        return _amount * 10 ** uint256(_decimal);
    }
}
