contract TimeStamps{


function getCurrentTimestamp() public view returns (uint256) {
    return block.timestamp;
}
//Implementing a time-based condition:
uint256 public deadline = block.timestamp + 1 days;

function isDeadlineReached() public view returns (bool) {
    return block.timestamp >= deadline;
}
uint256 public startTime;

function startTimer() public {
    startTime = block.timestamp;
}

function getTimeElapsed() public view returns (uint256) {
    require(startTime > 0, "Timer has not been started");
    return block.timestamp - startTime;
}

//Calculating the time elapsed since a specific timestamp:
uint256 public startTime;

function startTimer() public {
    startTime = block.timestamp;
}

function getTimeElapsed() public view returns (uint256) {
    require(startTime > 0, "Timer has not been started");
    return block.timestamp - startTime;
}

//Scheduling a future action based on a delay:
uint256 public actionDelay = 1 hours;
uint256 public scheduledActionTimestamp;

function scheduleAction() public {
    scheduledActionTimestamp = block.timestamp + actionDelay;
}

function isActionReady() public view returns (bool) {
    return block.timestamp >= scheduledActionTimestamp;
}


}

