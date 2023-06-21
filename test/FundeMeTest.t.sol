// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundeMeTest is Test {
    FundMe public fundme;

    function setUp() external {
        DeployFundMe deploy_fundme = new DeployFundMe();
        (fundme, ) = deploy_fundme.run();
        // fundme = new FundeMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    function testMinimumUSD() public {
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testOwnerAddress() public {
        assertEq(fundme.ownerAddress(), msg.sender);

        //......... us calling fundMeTest  AND   FundMeTest calling FundMe
        // address  1           2                    2              3  -> ownerAddress = 2
        // console.log(fundme.ownerAddress());
        // console.log(address(this));
        // console.log(msg.sender);
    }

    function testVersion() public {
        assertEq(fundme.version(), 4);
    }
}
