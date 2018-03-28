import { default as web3 } from 'web3'
import { default as contract } from 'truffle-contract'
import tokenArtifacts from '../build/contracts/PowerPiperToken.json'
const PowerPiperToken = contract(tokenArtifacts)

if (typeof web3 !== 'undefined') {
  web3 = new Web3(web3.currentProvider)
} else {
  web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'))
}

web3.eth.defaultAccount = web3.eth.accounts[0]
const PWP = PowerPiperToken.at(web3.eth.accounts[0])
const transferEvent = PWP.Transfer()
const kycEvent = PWP.KYC()
const purchaseEvent = PWP.TokenPurchase()

kycEvent.watch(function (error, result) {
  if (!error) {
    $('#loader').hide()
    $('#user').html(result.args.firstName + ' ' + result.args.lastName)
  } else {
    $('#loader').hide()
    console.log(error)
  }
})

$('#button').click(function () {
  PWP.setKYC($('#firstName').val(), $('#lastName').val())
})

// events:
// event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
// Transfer(address indexed from, address indexed to, uint256 value);

/*import './css/app.css'

var accounts
var account

window.App = {
  start: function () {
    var self = this
    PWP.setProvider(web3.providers.HttpProvider('http://127.0.0.1:8545'))

    web3.eth.getAccounts(function (err, accs) {
      if (err != null) {
        // alert('There was an error fetching your accounts.')
        return
      }

      if (accs.length === 0) {
        //alert(`Couldn't get any accounts! Make sure your Ethereum client is configured correctly.`)
        return
      }

      accounts = accs
      account = accounts[0]

      self.refreshBalance()
    })
  },

  setStatus: function (message) {
    var status = document.getElementById('status')
    status.innerHTML = message
  },

  refreshBalance: function () {
    var self = this

    var meta
    PWP.deployed().then(function (instance) {
      meta = instance
      return meta.getBalance.call(account, { from: account })
    }).then(function (value) {
      var balanceElement = document.getElementById('balance')
      balanceElement.innerHTML = value.valueOf()
    }).catch(function (e) {
      console.log(e)
      self.setStatus('Error getting balance; see log')
    })
  },

  sendCoin: function () {
    var self = this

    var amount = parseInt(document.getElementById('amount').value)
    var receiver = document.getElementById('receiver').value

    this.setStatus('Initiating transaction... (please wait)')

    var meta
    PWP.deployed().then(function (instance) {
      meta = instance
      return meta.sendCoin(receiver, amount, { from: account })
    }).then(function () {
      self.setStatus('Transaction complete!')
      self.refreshBalance()
    }).catch(function (e) {
      console.log(e)
      self.setStatus('Error sending coin; see log.')
    })
  }
}

window.addEventListener('load', function () {
  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    console.warn(`Using web3 detected from external source. If you find that your accounts don't appear or you have 0 PWP, ensure you've configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask`)
    // Use Mist/MetaMask's provider
    window.web3 = new web3(web3.providers.HttpProvider('http://127.0.0.1:8545'))
  }
  /*
  else {
    console.warn(`No web3 detected. Falling back to http://127.0.0.1:9545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask`)
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:9545'))
  }
  */
  /*window.App.start()
})
*/