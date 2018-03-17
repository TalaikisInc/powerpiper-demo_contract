const CoinCrowdsale = require('../contracts/PowerPiperCrowdsale.sol')
const truffleContract = require('truffle-contract')
const Web3 = require('web3')

const web3 = new Web3()
const provider = new web3.providers.HttpProvider('http://localhost:8545')

let ContractCrowdsaleInstance
const TruffleContractCrowdsaleInstance = truffleContract(CoinCrowdsale)
TruffleContractCrowdsaleInstance.setProvider(provider)

TruffleContractCrowdsaleInstance.deployed()
  .then(async instance => {
    ContractCrowdsaleInstance = instance
    const transaction = {
      from: web3.eth.accounts[2],
      value: web3.utils.toWei(5, 'ether'),
      gas: '90000'
    }
    const tx = await instance.sendTransaction(transaction)
    console.log(tx)
  })
