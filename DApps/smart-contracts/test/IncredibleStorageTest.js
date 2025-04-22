const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("IncredibleStorage", function () {
  let IncredibleStorage;
  let incredibleStorage;
  let owner;
  let addr1;
  let addr2;

  describe("Deployment", function () {
    it("Should set the correct initial value", async function () {
      expect(await incredibleStorage.get()).to.equal(42);
    });
  });

  describe("Transactions", function () {
    it("Should update the value when calling set", async function () {
      await incredibleStorage.set(100);
      expect(await incredibleStorage.get()).to.equal(100);
    });

    it("Should allow multiple updates", async function () {
      await incredibleStorage.set(100);
      await incredibleStorage.set(200);
      expect(await incredibleStorage.get()).to.equal(200);
    });

    it("Should emit an event when value is updated", async function () {
      await expect(incredibleStorage.set(100))
        .to.emit(incredibleStorage, "ValueUpdated")
        .withArgs(100);
    });
  });

  describe("Access Control", function () {
    it("Should allow any account to set a value", async function () {
      await incredibleStorage.connect(addr1).set(150);
      expect(await incredibleStorage.get()).to.equal(150);
    });

    it("Should allow any account to get the value", async function () {
      await incredibleStorage.set(200);
      expect(await incredibleStorage.connect(addr2).get()).to.equal(200);
    });
  });

  describe("Edge Cases", function () {
    it("Should handle setting to zero", async function () {
      await incredibleStorage.set(0);
      expect(await incredibleStorage.get()).to.equal(0);
    });

    it("Should handle setting to maximum uint256", async function () {
      const maxUint256 = ethers.constants.MaxUint256;
      await incredibleStorage.set(maxUint256);
      expect(await incredibleStorage.get()).to.equal(maxUint256);
    });
  });
});