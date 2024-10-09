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
    address[] collateralTokens; // Addresses of collateral tokens
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
    function liquidateUserRequest(uint96 requestId) external;
    function getRequestToColateral(
        uint96 _requestId,
        address _token
    ) external view returns (uint256);
    function getUsdValue(
        address _token,
        uint256 _amount,
        uint8 _decimal
    ) external view returns (uint256);
}

interface IERC20 {
    function decimals() external view returns (uint8);
}
