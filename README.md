# Step to create Foundry Project #
1. Run ` sudo nano /etc/resolv.conf ` and change IP to 8.8.8.8
2. After that run command ` forge init <name-of-project> `

# Compile Contract #
```
forge compile
    OR
forge build
```
Error in compilation (DNS faliure)
```
sudo nano /etc/resolv.conf
change to ----- nameserver 8.8.8.8
```

# Deploy Contract #
### Deploy with `forge` command ###
```
forge create <contract-name> --rpc-url <rpc-url-of-chain> --private-key <privatekey-of-wallet>
```
### Deploy with `script` ###
Script is the simple code which is use to deploy contract and this code is written in Solidity only. Script is written inside the src/ folder. 
script file contain some sort of namming convention `<name-of-the-file>.s.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol"; // this is what define this file as a script
import {SimpleStorage} from "../src/SimpleStorage.sol"; // import those contracts which we need to deploy

contract DeploySimpleStorage is Script {
    function run() external returns (SimpleStorage) {
        vm.startBroadcast(); // every thing after this line you need to send to RPC
        SimpleStorage simpleStorage = new SimpleStorage();  // this line send the transaction to create SimpleStorage contract
        vm.stopBroadcast();
        return simpleStorage;
    }
}
```

RUN COMMAND 
``` 
forge script script/<name-of-your-script>.s.sol --rpc-url <rpc-url-of-chain> --broadcast --private-key <private-key>
```


# Interact With Contract #
- ### with command line ###
for send trascation
```
cast send <contract-address> "function_name(passed_arg_type)" <arg_value> --rpc-url <rpc-url> --private-key <private-key>
```
for read value from contract
```
cast call <contract-address> "function"/variable_name()"
```
