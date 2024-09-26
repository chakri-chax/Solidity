// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.6/ConfirmedOwner.sol";

contract APIConsumer is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    uint256 public volume;  // Stores the requested volume data
    bytes32 private jobId;  // Chainlink Job ID to interact with the oracle
    uint256 private fee;    // Fee in LINK to pay for the oracle request

    event RequestVolume(bytes32 indexed requestId, uint256 volume);

    constructor(address _linkToken, address _oracle, bytes32 _jobId, uint256 _fee) ConfirmedOwner(msg.sender) {
        // Initialize Chainlink variables in constructor
        _setChainlinkToken(_linkToken);  // Set the LINK token address
        _setChainlinkOracle(_oracle);    // Set the Oracle address
        jobId = _jobId;                 // Set the Job ID
        fee = _fee;                     // Set the fee (in LINK tokens)
    }

    /**
     * Create a Chainlink request to retrieve API response.
     * Sends the request to the Oracle to get volume data from the API.
     */
    function requestData() public returns (bytes32 requestId) {
        Chainlink.Request memory req = _buildChainlinkRequest(
            jobId,             // The job ID that defines which task the oracle should execute
            address(this),      // The address of the contract making the request
            this.fulfill.selector // Callback function to handle the response
        );

        // Set the API URL to perform the GET request
        req.add("get", "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD");

        // Set the path to extract the desired data (volume)
        req.add("path", "RAW,ETH,USD,VOLUME24HOUR");

        // Multiply the result to adjust decimals
        int256 timesAmount = 10**18;
        req.addInt("times", timesAmount);

        // Send the request to the oracle and return the requestId
        return _sendChainlinkRequest(req, fee);
    }

    /**
     * Receive the response from the oracle.
     * This function is triggered when the oracle returns data.
     */
    function fulfill(bytes32 _requestId, uint256 _volume) public recordChainlinkFulfillment(_requestId) {
        emit RequestVolume(_requestId, _volume);  // Emit the event with the requestId and volume
        volume = _volume;  // Update the contract's volume variable with the new data
    }

    /**
     * Withdraw LINK tokens from the contract (onlyOwner).
     * Allows the owner to withdraw any leftover LINK tokens.
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(_chainlinkTokenAddress()); // Get the LINK token interface
        require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer tokens"); // Transfer LINK to owner
    }
}
