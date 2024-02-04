# `Library` #

- we need to import library first
- all functions need to be `internal` inside the library

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter{
    function addOne(uint256 num) internal view returns(uint256){
        return (num + 1);
    }

    function addTwoNumber(uint256 a,uint256 b) internal view returns(uint256){
        return (a + b);
    }
}
```
library is mainly use for code reusability, the functions in the library is access from different Smart Contracts.

### how to access functions inside the `library`? ###
- there are two methods to access functions inside the library

### With `using` ###
```solidity
import {PriceConverter} from "./PriceConverter.sol"
contract FundMe{
  using PriceConverter for uint256;
  uint256 num = 1;
  uint256 a = 2;
  uint256 b = 3;

  num = num.addOne();
  uint256 ans = a.addTwoNumber(b);
}
```

### Without `using` ###
```solidity
import {PriceConverter} from "./PriceConverter.sol"
contract FundMe{
  uint256 num = 1;
  uint256 a = 2;
  uint256 b = 3;

  num = PriceConverter.addOne(num);
  uint256 ans = PriceConverter.addTwoNumber(a,b);
}
```


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
