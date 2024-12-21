// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PeerLedWorkshops {
    address public owner;

    struct Workshop {
        string topic;
        address host;
        uint256 reward;
        bool isCompleted;
    }

    Workshop[] public workshops;

    event WorkshopCreated(uint256 workshopId, string topic, address indexed host, uint256 reward);
    event WorkshopCompleted(uint256 workshopId, address indexed host);

    modifier onlyHost(uint256 workshopId) {
        require(msg.sender == workshops[workshopId].host, "Only the host can perform this action.");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createWorkshop(string memory _topic, uint256 _reward) public payable {
        require(msg.value == _reward, "Ether sent must match the reward amount.");
        workshops.push(Workshop({
            topic: _topic,
            host: msg.sender,
            reward: _reward,
            isCompleted: false
        }));
        emit WorkshopCreated(workshops.length - 1, _topic, msg.sender, _reward);
    }

    function completeWorkshop(uint256 workshopId) public onlyHost(workshopId) {
        Workshop storage workshop = workshops[workshopId];
        require(!workshop.isCompleted, "Workshop already completed.");
        workshop.isCompleted = true;
        payable(workshop.host).transfer(workshop.reward);
        emit WorkshopCompleted(workshopId, msg.sender);
    }

    function getWorkshop(uint256 workshopId) public view returns (
        string memory topic,
        address host,
        uint256 reward,
        bool isCompleted
    ) {
        Workshop memory workshop = workshops[workshopId];
        return (workshop.topic, workshop.host, workshop.reward, workshop.isCompleted);
    }

    function getWorkshopCount() public view returns (uint256) {
        return workshops.length;
    }
}
