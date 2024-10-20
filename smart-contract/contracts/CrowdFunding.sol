// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract CrowdFunding {
    string public name;
    string public description;
    uint256 public goal;
    uint256 public deadline;
    address public owner;

    struct Tiers{
        string name;
        uint256 amount;
        uint256 backers;
    }

    Tiers[] public tiers;

    modifier onlyOwner(){
        require(msg.sender == owner, "You're not the owner");
        _;
    }

    constructor(
        string memory _name,
        string memory _description,
        uint256 _goal,
        uint256 _durationPerDays
    ){
        name = _name;
        description = _description;
        goal = _goal;
        deadline = block.timestamp + (_durationPerDays * 1 days);
        owner = msg.sender;
    }

    function addTier(string memory _name, uint256 _amount) public onlyOwner{
        require(_amount > 0, "The amount must be greater than 0");
        tiers.push(Tiers(_name, _amount, 0 ));
    }

    function removeTier(uint256 _index) public onlyOwner{
        require(_index < tiers.length, "Tier doesn't exist");
        tiers[_index] = tiers[tiers.length - 1];
        tiers.pop();
    }

    function fund(uint256 _tierIndex) public payable {
        require(block.timestamp < deadline, "Campaign has already ended");
        require(_tierIndex < tiers.length, "Invalid Tier");
        require(msg.value == tiers[_tierIndex].amount, "Incorrect amount");

        tiers[_tierIndex].backers++;
    }

    function withdraw() public onlyOwner {
        require(msg.sender == owner, "Only the owner can withdraw");
        require(address(this).balance >= goal, "Goal has not been reached yet");

        uint256 balance = address(this).balance;
        require(balance > 0, "Nothing to withdraw");

        payable(owner).transfer(balance);
    }

    function getContractBalance() public view returns (uint256){
        return address(this).balance;
    }
}