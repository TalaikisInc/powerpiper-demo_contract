require('babel-register')
require('babel-polyfill')
const Web3 = require('web3')
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"))
const PowerPiperToken = artifacts.require('./PowerPiperToken.sol')
const PowerPiperCrowdsale = artifacts.require('./PowerPiperCrowdsale.sol')
const Migrations = artifacts.require("./Migrations.sol")
// const Convertlib = artifacts.require('./Convertlib.sol')
// const Exchange = artifacts.require('./Exchange.sol')

module.exports = function(deployer, network, accounts) {
  const _openingTime = web3.eth.getBlock('latest').timestamp + 20; // ICO after 20 s
  const _closingTime = _openingTime + 86400 * 10; // 10 days
  const _rate = 3000
  const _wallet = accounts[0] // owner address
  const _cap = web3.toWei(555, 'ether')
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
          _cap * _rate
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
    .then(async () => {
      const instance = await PowerPiperCrowdsale.deployed()
      const token = await instance.token.call()
      console.log('Token address', token)
      console.log('start: ', _openingTime)
      console.log('end: ', _closingTime)
      console.log('rate: ', _rate.toString())
      console.log('wallet: ', _wallet)
      console.log(' capInWei:', _cap)
    })

}
