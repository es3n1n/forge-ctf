// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Script.sol";
import "forge-ctf/CTFChallenge.sol";

abstract contract CTFDeployer is Script {
    function run() external {
        address player = getAddress(0);
        address system = getAddress(1);

        CTFChallenge[] memory challenges = deploy(system, player);

        // note(es3n1n, 28.03.24): please don't pass " or \n or any other shit like this, this thing would break!
        string memory result = "";
        for (uint i = 0; i < challenges.length; i++) {
            result = string(
                abi.encodePacked(
                    result,
                    "[\"",
                    challenges[i].name,
                    "\",\"",
                    vm.toString(challenges[i].contractAddress),
                    "\"]\n"
                )
            );
        }

        vm.writeFile(vm.envOr("OUTPUT_FILE", string("/tmp/deploy.txt")), result);
    }

    function deploy(address system, address player) virtual internal returns (CTFChallenge[] memory);
    
    function getAdditionalAddress(uint32 index) internal returns (address) {
        return getAddress(index + 2);
    }

    function getPrivateKey(uint32 index) private returns (uint) {
        string memory mnemonic = vm.envOr("MNEMONIC", string("test test test test test test test test test test test junk"));
        return vm.deriveKey(mnemonic, index);
    }

    function getAddress(uint32 index) private returns (address) {
        return vm.addr(getPrivateKey(index));
    }
}