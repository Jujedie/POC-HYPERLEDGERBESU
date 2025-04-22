const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("IncredibleStorage", function () {
	let IncredibleStorage;
	let incredibleStorage;
	let owner;

	beforeEach(async function () {
		IncredibleStorage = await ethers.getContractFactory("IncredibleStorage");
		[owner] = await ethers.getSigners();
    
		incredibleStorage = await IncredibleStorage.deploy(42);
	});

	it("Should have a default value", async function () {
		expect(await incredibleStorage.get()).to.equal(42);
	});
});

