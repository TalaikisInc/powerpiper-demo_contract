require('babel-register')
require('babel-polyfill')
const PowerPiperToken = artifacts.require('./PowerPiperToken.sol')
// const Convertlib = artifacts.require('./Convertlib.sol')
const PowerPiperCrowdsale = artifacts.require('./PowerPiperCrowdsale.sol')
const Exchange = artifacts.require('./Exchange.sol')
const Migrations = artifacts.require("./Migrations.sol")
const BigNumber = web3.BigNumber

module.exports = function(deployer, network, accounts) {
  const _openingTime = web3.eth.getBlock('latest').timestamp + 200; // ICO after 200 s
  const _closingTime = _openingTime + 86400 * 10; // 10 days
  const _rate = new BigNumber(3000); // 3000 PWP for 1 ETH
  const _wallet = accounts[0] // owner address
  const _cap = 100000
  const _name = 'PowerPiperToken'
  const _symbol = 'PWP'
  const _decimals = 3
  const _goal = 10

  return deployer
    .then(() => {
      return deployer.deploy(Migrations)
    })
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
    /*.then(() => {
      return deployer.link(PowerPiperToken, Exchange)
    })
    .then(() => {
      return deployer.deploy(Exchange, _wallet)
    })*/
    .then(() => {
      return deployer.deploy(
        PowerPiperCrowdsale,
          _openingTime,
          _closingTime,
          _rate,
          _cap,
          _wallet,
          PowerPiperToken.address,
          _goal,
          { from: _wallet }
      )
    })

}
