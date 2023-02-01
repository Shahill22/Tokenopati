const AccuCoin = artifacts.require("AccuCoin");
const Cryptopati = artifacts.require("Cryptopati");

module.exports = async function (deployer, network, accounts) {
  const platform = "0x6ed66c2956f7c2bb7b970da6fee906bca02386b7" // Defender Relayer account
  await deployer.deploy(AccuCoin);
  const accuCoin = await AccuCoin.deployed();

  await deployer.deploy(Cryptopati, accuCoin.address, platform);
  const cryptopati = await Cryptopati.deployed();

  await accuCoin.addToWhitelist(cryptopati.address);
  await accuCoin.addMinterRole(cryptopati.address);
};
