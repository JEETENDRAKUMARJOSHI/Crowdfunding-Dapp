// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract Crowdfunding {

    uint256 public deadline;
    uint256 public targetFund;
    string public name;
    address public owner ;
    bool fundWithdrawl ;


    mapping(address => uint256) public funders;
    
    event funded(address _funder, uint256 _amount);
    event OwnerWithdrawal(uint256 _amount);
    event funderWithdrawl(address _funder, uint256 _amount);

    constructor(string memory _name, uint256 _targetFund, uint256 _deadline) {
        owner = msg.sender;
        name = _name;
        targetFund = _targetFund;
        deadline = _deadline;        
    }

    function isFundenable() public view returns(bool){
        if(block.timestamp>deadline || fundWithdrawl){
            return true;
        }else{
            return false;
        }
    }

    function isFundSuccess() public view returns(bool){
        if(address(this).balance >=targetFund || fundWithdrawl){
            return true;
        }else{
            return false;
        }
    }

    function fund() public payable{
        require(isFundenable() == true, "Fund is disabled.");
        funders[msg.sender] += msg.value;
        emit funded(msg.sender, msg.value);
    }

    function withdrawOwner() public{
        require(msg.sender == owner, "Not Authorized");
        require(isFundSuccess()==true, "Cannot Withdraw");
        uint256 amountToSend = address(this).balance;
        (bool success,) = msg.sender.call{value:amountToSend}("");

        require(success,"Unable to send");
        fundWithdrawl = true;

        emit OwnerWithdrawal(amountToSend);
    }

    function withdrawOFunder() public{
        require(isFundenable()== true && isFundSuccess() == false, "Not Eligible");
        uint256  amountToSend = funders[msg.sender];
        (bool success,) = msg.sender.call{value: amountToSend}("");

        require(success,"Unable to send");
        funders[msg.sender] = 0;

        emit funderWithdrawl(msg.sender, amountToSend);
    }

}