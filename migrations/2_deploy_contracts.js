const AccuCoin = artifacts.require("AccuCoin");
const Cryptopati = artifacts.require("Cryptopati");
//const platform = process.env;

module.exports = async function (deployer, network, accounts) {
  const [, platform] = accounts;
  //await deployer.deploy(AccuCoin);
  const accuCoin = await AccuCoin.deployed();

  await deployer.deploy(Cryptopati, accuCoin.address, platform);
  const cryptopati = await Cryptopati.deployed();

  await accuCoin.addToWhitelist(cryptopati.address);
  await accuCoin.addMinterRole(cryptopati.address);
};
