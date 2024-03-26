// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;




error NotOwner();

contract FundMe {


    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    address public /* immutable */ i_owner;
  
    
    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {

        addressToAmountFunded[msg.sender] += msg.value;

        //looping through the funders array array to check if the adderess also is in the array
        for (uint256 i = 0; i < funders.length; i++) 
        {
            
            if (funders[i] == msg.sender){
                 // If the code reaches here it means that the sender's address already is in funders array
                 // So there is no need to push the address again, the function returns
                   return;
            }
        }
        // If the code does not return before this, it means the senders address does not exist in funders array
        // so the address is to be pushed to the array
        funders.push(msg.sender);
        
    }
    
  
    
    modifier onlyOwner {
       
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }
    
    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
     
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
    
    // simple function to tranfer ownership to new address, which can be only perfomed by the current owner
    function transferOwnership(address newOwner) public onlyOwner{
        i_owner =newOwner;
    }
    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \ 
    //         yes  no
    //         /     \
    //    receive()?  fallback() 
    //     /   \ 
    //   yes   no
    //  /        \
    //receive()  fallback()

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

}
