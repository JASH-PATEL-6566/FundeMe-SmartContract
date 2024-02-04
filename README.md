# Send ETH #

function need to have `payable` keywword if we need to use that for send eth.

```solidity
function fund() public payable {
  require(msg.value.getConvertionRate() > minimumUsd,"Didn't send enough ETH.");
  funders.push(msg.sender);
  addressToAmountFunded[msg.sender] += msg.value;
}
```



`require(condition,error message)` | if the condition is `true` at that moment the value which is send to that transaction is stored in SmartContract's balance if the condition is `false` the transaction get revert|
--- | --- |

# Withdraw ETH #

1. ### `Transfer` ###
   problem : 2300 gas limit, if gas is greater than 2300 error thrown
   ```solidity
   function withdraw() public{
     payable(msg.sender).transfer(address(this).balance);
   }
   ```
2. ### `Send` ###
  problem : 2300 gas limit, return boolean, if `< 2300` return true ---- `> 2300` return false 
   ```solidity
   function withdraw() public{
     bool sendSuccess = payable(msg.sender).send(address(this).balance);
     require(sendSuccess,"Send failed!");
   }
   ```
3. ### `Call` ###
  best way to withdraw ETH
   ```solidity
   function withdraw() public{
     bool callSuccess = payable(msg.sender).call{value : address(this).balance}("");
     require(callSuccess,"Send failed!");
   }
   ```
