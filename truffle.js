require('babel-register')
require('babel-polyfill')
const prod = process.env.ENV === 'production'
const envLoc = prod ? './.env' : './.env'
require('dotenv').config({ path: envLoc })
const crypt = require('./crypto')
const WalletProvider = require('truffle-hdwallet-provider-privkey')

const config = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 8545,
      network_id: 336
    }/*,
    rinkeby: {
      provider: new WalletProvider(crypt.decrypt(process.env.PRIVATE_KEY, process.env.ENCRYPTION_PASSWORD),
        'https://rinkeby.infura.io/' + crypt.decrypt(process.env.INFURA_API_KEY, process.env.ENCRYPTION_PASSWORD)),
      network_id: 4,
      gas: 4700036,
      gasPrice: 130000000000
    },
    ropsten: {
      provider: new WalletProvider(crypt.decrypt(process.env.PRIVATE_KEY, process.env.ENCRYPTION_PASSWORD),
        'https://ropsten.infura.io/' + crypt.decrypt(process.env.INFURA_API_KEY, process.env.ENCRYPTION_PASSWORD)),
      network_id: 3,
      gas: 4700036,
      gasPrice: 130000000000
    }*/,
    coverage: {
      host: 'localhost',
      network_id: '*',
      port: 8545,
      gas: 0xfffffffffff,
      gasPrice: 0x01
    }
  }
 }
module.exports = config
