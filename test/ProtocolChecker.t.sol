// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./mocks/MockProtocol.sol";
import "./mocks/MockToken.sol";
import "../src/interface/IProtocol.sol";
import "../src/ProtocolChecker.sol";

contract ProtocolCheckerTest is Test {
    MockProtocol public protocol;
    ProtocolChecker public protocolChecker;

    function setUp() public {
        // Deploy the MockProtocol contract
        protocol = new MockProtocol();
        protocolChecker = new ProtocolChecker();
        address loanAddress = address(new MockToken());

        // Create 10 loan requests
        address[] memory collateralTokens = new address[](1);
        collateralTokens[0] = address(new MockToken()); // Mock collateral token address

        // Half of the requests will have insufficient collateral (health factor below 1)
        for (uint96 i = 0; i < 5; i++) {
            uint256[] memory collateralAmounts = new uint256[](1);
            collateralAmounts[0] = 400 ether; // Insufficient collateral (loan amount is 1000)
            protocol.createRequest(
                loanAddress,
                1000 ether,
                5,
                1100 ether,
                block.timestamp + 30 days,
                Status.SERVICED,
                collateralTokens,
                collateralAmounts
            );
        }

        // The other half will have sufficient collateral (health factor >= 1)
        for (uint96 i = 5; i < 10; i++) {
            uint256[] memory collateralAmounts = new uint256[](1);
            collateralAmounts[0] = 1200 ether; // Sufficient collateral
            protocol.createRequest(
                loanAddress,
                1000 ether,
                5,
                1100 ether,
                block.timestamp + 30 days,
                Status.SERVICED,
                collateralTokens,
                collateralAmounts
            );
        }
    }

    function testChecker() external view {
        (bool _canExec, bytes memory _execPayload) = protocolChecker.checker(
            address(protocol)
        );
        console.log(_canExec);
    }
}
