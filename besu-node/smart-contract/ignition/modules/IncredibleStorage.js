const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("IncredibleStorageModule", (m) => {
	const incredibleStorage = m.contract("IncredibleStorage", [42], { });
	return { incredibleStorage };
});
