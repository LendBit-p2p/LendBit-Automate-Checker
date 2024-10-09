// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interface/IProtocol.sol";

contract ProtocolChecker {
    function getServicedRequest(
        address _protocol
    ) internal view returns (Request[] memory servicedRequest) {
        Request[] memory allRequests = IProtocol(_protocol).getAllRequest();
        uint256 servicedRequestlen = servicedRequest.length;
        for (uint i = 0; i < allRequests.length; i++) {
            if (allRequests[i].status == Status.SERVICED) {
                servicedRequest[servicedRequestlen] = allRequests[i];
                servicedRequestlen++;
            }
        }
    }

    function _getRequestHealthFactor(
        Request memory _request,
        address _protocol
    ) internal view returns (uint256 _factor) {
        address[] memory _collateralTokens = _request.collateralTokens;
        uint256 _loanRepayment = _request.totalRepayment;
        address _borrowedToken = _request.loanRequestAddr;
        uint8 _borrowedTokenDecimal = IERC20(_borrowedToken).decimals();

        uint256 _loanRepaymentInUsd = IProtocol(_protocol).getUsdValue(
            _borrowedToken,
            _loanRepayment,
            _borrowedTokenDecimal
        );

        uint256 _collateralTokenInusd = 0;

        for (uint8 i = 0; i < _collateralTokens.length; i++) {
            uint8 _collateralDecimal = IERC20(_collateralTokens[i]).decimals();
            uint256 _collateralAmount = IProtocol(_protocol)
                .getRequestToColateral(
                    _request.requestId,
                    _collateralTokens[i]
                );

            _collateralTokenInusd += IProtocol(_protocol).getUsdValue(
                _collateralTokens[i],
                _collateralAmount,
                _collateralDecimal
            );
        }

        _factor = (_collateralTokenInusd * 1E18) / _loanRepaymentInUsd;
    }

    function checker(
        address _protocol
    ) external view returns (bool canExec, bytes memory execPayload) {
        Request[] memory requests = getServicedRequest(_protocol);

        for (uint i = 0; i < requests.length; i++) {
            uint256 _healthFactor = _getRequestHealthFactor(
                requests[i],
                _protocol
            );

            execPayload = abi.encodeWithSelector(
                IProtocol.liquidateUserRequest.selector,
                requests[i].requestId
            );

            if ((_healthFactor / 1E18) < 1) {
                return (true, execPayload);
            }
        }
        return (false, bytes("No Faulters"));
    }
}
