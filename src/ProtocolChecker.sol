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

    function checker(
        address _protocol
    ) external view returns (bool canExec, bytes memory execPayload) {
        Request[] memory requests = getServicedRequest(_protocol);

        for (uint i = 0; i < requests.length; i++) {
            address _user = requests[i].author;
            uint8 _healthFactor = IProtocol(_protocol).getHealthFactor(_user);

            execPayload = abi.encodeWithSelector(
                IProtocol.handleLiquidationRequest.selector,
                _user
            );

            if (_healthFactor < 1) {
                return (true, execPayload);
            }
        }
        return (false, bytes("No Faulters"));
    }
}
