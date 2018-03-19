require('babel-register')
require('babel-polyfill')
const PowerPiperToken = artifacts.require('./PowerPiperToken.sol')
const Convertlib = artifacts.require('./Convertlib.sol')
const PowerPiperCrowdsale = artifacts.require('./PowerPiperCrowdsale.sol')

module.exports = function(deployer, network, accounts) {
  const _openingTime = web3.eth.getBlock('latest').timestamp + 2; // ICO after 1 s
  const _closingTime = _openingTime + 86400 * 10; // 10 days
  const _rate = new web3.BigNumber(1000); // 1000 PWP for 1 ETH
  const _wallet = accounts[0] // owner address
  const _cap = 1000000
  const _name = 'PowerPiperToken'
  const _symbol = 'PWP'
  const _decimals = 3

  return deployer
    /*.then(() => {
      return deployer.deploy(Convertlib)
    })
    .then(() => {
      return deployer.link(PowerPiperToken, Convertlib)
    })*/
    .then(() => {
        return deployer.deploy(PowerPiperToken,
          _name,
          _symbol,
          _decimals
        )
    })
    .then(() => {
      return deployer.deploy(
        PowerPiperCrowdsale,
          _openingTime,
          _closingTime,
          _rate,
          _cap,
          _wallet,
          PowerPiperToken.address
      )
    })

}
