// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract IncredibleStorage {
	uint awesomeUInt;

	constructor(uint _awesomeUInt) {
		awesomeUInt = _awesomeUInt;
	}	

	function set(uint x) public {
		awesomeUInt = x;
	}

	function get() public view returns (uint) {
		return awesomeUInt;
	}
}
