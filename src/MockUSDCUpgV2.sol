// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Upgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import {Initializable} from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import {ERC1967Utils} from "lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";

contract MockUSDCUpgV2 is ERC20Upgradeable {
    function getAdmin() public view returns (address) {
        return ERC1967Utils.getAdmin();
    }

    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __ERC20_init("MockUSDC", "USDC");
        // _mint(msg.sender, 1000000000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function version() public pure returns (string memory) {
        return "2.0.0";
    }
}
