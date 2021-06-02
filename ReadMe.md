# Upgradable contract

## Installation

```
npm install
```

This package requires Truffle [version 5.1.35](https://github.com/trufflesuite/truffle/releases/tag/v5.1.35) or greater.

## Usage in migrations

To deploy an upgradable contract, run following command
```
truffle migrate --network bscTestnet --reset
```

## Usage in migrations

To deploy an upgradeable instance of one of your contracts in your migrations, use the `deployProxy` function:

```js
// migrations/NN_deploy_upgradeable_box.js
const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const Box = artifacts.require('Box');

module.exports = async function (deployer) {
  const instance = await deployProxy(Box, [42], { deployer });
  console.log('Deployed', instance.address);
};
```

This will automatically check that the `Box` contract is upgrade-safe, set up a proxy admin (if needed), deploy an implementation contract for the `Box` contract (unless there is one already from a previous deployment), create a proxy, and initialize it by calling `initialize(42)`.

Then, in a future migration, you can use the `upgradeProxy` function to upgrade the deployed instance to a new version. The new version can be a different contract (such as `BoxV2`), or you can just modify the existing `Box` contract and recompile it - the plugin will note it changed.

```js
// migrations/MM_upgrade_box_contract.js
const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const Box = artifacts.require('Box');
const BoxV2 = artifacts.require('BoxV2');

module.exports = async function (deployer) {
  const existing = await Box.deployed();
  const instance = await upgradeProxy(existing.address, BoxV2, { deployer });
  console.log("Upgraded", instance.address);
};
```

The plugin will take care of comparing `BoxV2` to the previous one to ensure they are compatible for the upgrade, deploy the new `BoxV2` implementation contract (unless there is one already from a previous deployment), and upgrade the existing proxy to the new implementation.
