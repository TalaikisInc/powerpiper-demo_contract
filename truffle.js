require('babel-register')
require('babel-polyfill')
const prod = process.env.ENV === 'production'
const envLoc = prod ? './.env' : './.env.sample'
require('dotenv').config({ path: envLoc })
const crypt = require('./crypto')

const WalletProvider = require('truffle-hdwallet-provider-privkey')

const config = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 8545,
      //gas: 15e6,
      //gasPrice: 0x01,
      network_id: '*' // Match any network id
    },
    /*ropsten: {
      provider: new WalletProvider(crypt.decrypt(process.env.PRIVATE_KEY, process.env.PASS),
        'https://ropsten.infura.io/' + crypt.decrypt(process.env.API_KEY, process.env.PASS)),
      network_id: 3,
      gas: 4700036,
      gasPrice: 130000000000
    },*/
    coverage: {
      host: 'localhost',
      network_id: '*',
      port: 8555,
      gas: 0xfffffffffff,
      gasPrice: 0x01
    }
  }
 }
module.exports = config
