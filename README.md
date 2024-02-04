# `Modifier` #

let's say we need to perform require function at very first line and if condition is true then we need to perform reset of the code and we need to do this stuff in many functions so there is 2 ways we manually write require condition in first line of every function but this is not a best practice so best thing to do is use `modifier`.

```solidity

contract FundMe{
    function func1() public firstRun{
        // code ......
    }

    function func2() public lastRun{
        // code ......
    }

    modifier firstRun(){
        require(msg.value > 2,"send it");
        _;
    }

    modifier lastRun(){
        _;
        require(msg.value > 3,"send it");
    }
}
```

| Function | Explaination |
--- | --- |
`firstRun()` | those functions which contain this modifier, in those functions the code which is in modifier is execute first and then the code in function
`lastRun()` | those functions which contain this modifier, in those functions the code which is in modifier is execute last after execution of functions code



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


# Cost Efficient #

- use constant OR immutable keyword with variable
  
| Keyword | Usage |
--- | --- |
`constant` | is used with the variable which is define at the time per declaration and we cannot change the value of this variable
`immutable` | is used with the variable which is define after declaration, once the variable is define we cannot change that value

- avoid using require, bcz the string which is given as a error message take too much gas, insted use default error and `revert` keyword

```solidity
error NotOwner();

contract FundMe(){
    function checkOwner() public{
        // reuire(msg.sender == owner, "Not a oner");
        // use this
        if(msg.sender != owner){
            revert NotOwner()
        }
    }
}
```

# Special Functions #

- ### `receive()` ###

let's understand the use case, let say someone send some ETH directly without calling function in your Smart Contract which handles deposite, at this case it won't we accepted, if we use receive function at that time in this condition this functions get triger. 

```
IMPORTANT : main thing which we keep in mind is transaction does not have any kind of CALLDATA in it.
```

```solidity

contract FundMe{
    function fund() public payable{
        // code which accept payment from user
    }

    receive() external payable{
        fund();
    }
}
```

- ### `fallback()` ###

it works completely same as receive function. `MAIN DIIFERENCE` is that it also accept the transaction with CALLDATA.

```solidity

contract FundMe{
    function fund() public payable{
        // code which accept payment from user
    }

    fallback() external payable{
        fund();
    }
}
```

```
         is msg.data empty?
              /  \
            yes  no
            /      \
      receive()?   fallback()
        /    \
      yes    no
      /        \ 
   receive()  fallback()
```
