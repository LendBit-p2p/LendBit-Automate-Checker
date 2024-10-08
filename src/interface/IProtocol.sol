// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct Request {
    uint96 requestId;
    address author;
    uint256 amount;
    uint16 interest;
    uint256 totalRepayment;
    uint256 returnDate;
    address lender;
    address loanRequestAddr;
    Status status;
}

enum Status {
    OPEN,
    SERVICED,
    CLOSED
}

interface IProtocol {
    function getHealthFactor(address _user) external view returns (uint8);
    function getAllRequest() external view returns (Request[] memory);
    function handleLiquidationRequest(address _user) external;
}
