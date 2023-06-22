// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundeMeTest is Test {
    FundMe public fundme;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deploy_fundme = new DeployFundMe();
        (fundme, ) = deploy_fundme.run();
        vm.deal(USER, STARTING_BALANCE);
        // fundme = new FundeMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    function testMinimumUSD() public {
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testOwnerAddress() public {
        address ownerAddress = fundme.getOwnerAddress();
        assertEq(ownerAddress, msg.sender);
        //......... us calling fundMeTest  AND   FundMeTest calling FundMe
        // address  1           2                    2              3  -> ownerAddress = 2
        // console.log(fundme.ownerAddress());
        // console.log(address(this));
        // console.log(msg.sender);
    }

    function testVersion() public {
        assertEq(fundme.version(), 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundme.fund();
    }

    function testFundUpdateDataStructure() public funded {
        uint256 fund = fundme.getAddressToFunded(USER);
        assertEq(fund, SEND_VALUE);
    }

    function testCheckAddFunderToFundersArray() public funded {
        address funderAddress = fundme.getFunder(0);
        assertEq(funderAddress, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        fundme.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        uint256 startingOwnerBalance = fundme.getOwnerAddress().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        vm.prank(fundme.getOwnerAddress());
        fundme.withdraw();

        uint256 endingOwnerBalance = fundme.getOwnerAddress().balance;
        uint256 endingFundMeBalace = address(fundme).balance;

        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );
        assertEq(endingFundMeBalace, 0);
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 10;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), STARTING_BALANCE);
            fundme.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundme.getOwnerAddress().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        vm.startPrank(fundme.getOwnerAddress());
        fundme.withdraw();
        vm.stopPrank();

        uint256 endingOwnerBalance = fundme.getOwnerAddress().balance;
        uint256 endingFundMeBalace = address(fundme).balance;

        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );
        assertEq(endingFundMeBalace, 0);
    }

    modifier funded() {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        _;
    }
}
