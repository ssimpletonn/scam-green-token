const GreenToken = artifacts.require("GreenToken");
const ScamBank = artifacts.require("ScamBank");

module.exports = async function (deployer) {
  await deployer.deploy(GreenToken, 1000);
  const token = await GreenToken.deployed();
  await deployer.deploy(ScamBank, token.address);
};