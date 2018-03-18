require('babel-register')
require('babel-polyfill')
const PowerPiperToken = artifacts.require('./PowerPiperToken.sol')
const Convertlib = artifacts.require('./Convertlib.sol')
const PowerPiperCrowdsale = artifacts.require('./PowerPiperCrowdsale.sol')

module.exports = function(deployer, network, accounts) {
  const openingTime = web3.eth.getBlock('latest').timestamp + 2; // ICO after 1 s
  const closingTime = openingTime + 86400 * 10; // 10 days
  const rate = new web3.BigNumber(1000); // 1000 PWP for 1 ETH
  const wallet = accounts[0] // owner address
  const cap = 1000000

  return deployer
    /*.then(() => {
      return deployer.deploy(Convertlib)
    })
    .then(() => {
      return deployer.link(PowerPiperToken, Convertlib)
    })*/
    .then(() => {
        return deployer.deploy(PowerPiperToken)
    })
    .then(() => {
      return deployer.deploy(
        PowerPiperCrowdsale,
          openingTime,
          closingTime,
          rate,
          cap,
          wallet,
          PowerPiperToken.address
      )
    })

}
