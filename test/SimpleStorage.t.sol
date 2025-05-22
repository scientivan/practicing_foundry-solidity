pragma solidity ^0.8.19;
 
import "forge-std/Test.sol";
import "../src/SimpleStorage.sol";

contract SimpleStorageTest is Test{
    SimpleStorage public simpleStorage;
    
    function setUp() public {
        // membuat object dari class SimpleStorage
        simpleStorage = new SimpleStorage();
    }
    function testInitialValueIsZero() public{
        // getter function dari simpleStorage
        uint256 value = simpleStorage.retrieve();
        // ngeassign value = 0 
        assertEq(value,0);
    }
    
    function testStoreAndRetrieveValue() public {
        simpleStorage.store(34);
        uint256 value = simpleStorage.retrieve();
        assertEq(value,34);
    }

    function testAddPerson() public {
        simpleStorage.addPerson("Dien", 34);
        simpleStorage.addPerson("Faatira", 30);
        (uint256 favNum, string memory name) = simpleStorage.listOfPeople(0);
        (uint256 favNum2, string memory name2) = simpleStorage.listOfPeople(1);
        // assertEq(...) digunakan untuk memastikan bahwa kontrak benar-benar menyimpan nilai dengan benar.
        assertEq(favNum,34);
        assertEq(name,"Dien");
        assertEq(favNum2,30);
        assertEq(name2,"Faatira");
        assertEq(simpleStorage.nameToFavoriteNumber("Dien"),34);
        assertEq(simpleStorage.nameToFavoriteNumber("Faatira"),30);
    }
} 