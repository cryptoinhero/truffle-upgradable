const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');
const Escrow = artifacts.require('Escrow');
const isUpgrade = false;

module.exports = async function(deployer) {
  if(!isUpgrade) {
    // IBEP20 _token, address _wallet, uint256 _depositFee, uint256 _withdrawFee
    const instance = await deployProxy(Escrow, ["0xxxxxxxxx", "0xxxxxxxxx", 0, 0], { deployer });
    console.log('Deployed', instance.address);
  } else {
    const oldAddress = "0xxxxxxxxxxx"
    const instance = await upgradeProxy(oldAddress, Escrow, { deployer });
    console.log("Upgraded", instance.address);
  }
};
