const HDWalletProvider = require("@truffle/hdwallet-provider");
require("dotenv").config();

const mnemonic = process.env.MNEMONIC;
const infuraProjectId = process.env.INFURA_PROJECT_ID;
const etherscanApiKey = process.env.ETHERSCAN_API_KEY;
const snowtraceApiKey = process.env.SNOWTRACE_API_KEY;
const bscscanApiKey = process.env.BSCSCAN_API_KEY;

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
      gas: 6721975,
    },
    goerli: {
      networkCheckTimeout: 60000,
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          `https://goerli.infura.io/ws/v3/${infuraProjectId}`
        ),
      network_id: 5,
      confirmations: 2,
      timeoutBlocks: 1000,
      skipDryRun: true,
    },
    rinkeby: {
      networkCheckTimeout: 60000,
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          `wss://rinkeby.infura.io/ws/v3/${infuraProjectId}`
        ),
      network_id: 4,
      confirmations: 2,
      timeoutBlocks: 1000,
      skipDryRun: true,
    },
    kovan: {
      networkCheckTimeout: 60000,
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          `wss://kovan.infura.io/ws/v3/${infuraProjectId}`
        ),
      network_id: 4,
      confirmations: 2,
      timeoutBlocks: 1000,
      skipDryRun: true,
    },
    avalanche_testnet: {
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          `https://api.avax-test.network/ext/bc/C/rpc`
        ),
      network_id: 43113,
      gas: 5500000,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
    bsc_testnet: {
      provider: function () {
        return new HDWalletProvider({
          mnemonic: {
            phrase: mnemonic,
          },
          providerOrUrl: `https://data-seed-prebsc-1-s1.binance.org:8545`,
          chainId: 97,
        });
      },
      network_id: 97,
      // confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true,
      chainId: 97,
    },
    bsc: {
      provider: function () {
        return new HDWalletProvider({
          mnemonic: {
            phrase: mnemonic,
          },
          providerOrUrl: `https://bsc-dataseed1.binance.org`,
          chainId: 56,
        });
      },
      network_id: 56,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true,
      chainId: 56,
    },
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.17", // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {
        // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 200,
        },
        evmVersion: "byzantium",
      },
    },
  },
  plugins: ["truffle-plugin-verify"],
  api_keys: {
    etherscan: etherscanApiKey,
    snowtrace: snowtraceApiKey,
    bscscan: bscscanApiKey,
  },
};
