import decodeLogs from './helpers/decodeLogs'
const PowerPiperToken = artifacts.require('./PowerPiperToken.sol')

contract('PowerPiperToken', function (accounts) {
  let token
  const creator = accounts[0]

  beforeEach(async function () {
    token = await PowerPiperToken.new({ from: creator })
  })

  it('has initial supply of 10,000 tokens', async function () {
    const decimals = await token.totalSupply()
    assert(decimals.eq(10000))
  })

  it('assigns the initial total supply to the creator', async function () {
    const totalSupply = await token.totalSupply()
    const creatorBalance = await token.balanceOf(creator)

    assert(creatorBalance.eq(totalSupply))

    const receipt = web3.eth.getTransactionReceipt(token.transactionHash)
    const logs = decodeLogs(receipt.logs, PowerPiperToken, token.address)
    assert.equal(logs.length, 1)
    assert.equal(logs[0].event, 'Transfer')
    assert.equal(logs[0].args.from.valueOf(), 0x0)
    assert.equal(logs[0].args.to.valueOf(), creator)
    assert(logs[0].args.value.eq(totalSupply))
  })

  it('should have 10000 tokens in the first account', function () {
    return PowerPiperToken.deployed().then(function (instance) {
      return instance.balanceOf.call(creator)
    }).then(function (balance) {
      assert.equal(balance.valueOf(), 10000, `10000 wasn't in the first account`)
    })
  })

  it('should send token correctly', function () {
    var i

    // Get initial balances of first and second account.
    var accountOne = creator
    var accountTwo = accounts[1]

    var accountOneStartingBalance
    var accountTwoStartingBalance
    var accountOneEndingBalance
    var accountTwoEndingBalance

    var amount = 10

    return PowerPiperToken.deployed().then(function (instance) {
      i = instance
      return i.balanceOf.call(accountOne)
    }).then(function (balance) {
      accountOneStartingBalance = balance.toNumber()
      return i.balanceOf.call(accountTwo)
    }).then(function (balance) {
      accountTwoStartingBalance = balance.toNumber()
      return i.transfer(accountTwo, amount, { from: accountOne })
    }).then(function () {
      return i.balanceOf.call(accountOne)
    }).then(function (balance) {
      accountOneEndingBalance = balance.toNumber()
      return i.balanceOf.call(accountTwo)
    }).then(function (balance) {
      accountTwoEndingBalance = balance.toNumber()

      assert.equal(accountOneEndingBalance, accountOneStartingBalance - amount,
        `Amount wasn't correctly taken from the sender`)
      assert.equal(accountTwoEndingBalance, accountTwoStartingBalance + amount,
        `Amount wasn't correctly sent to the receiver`)
    })
  })
})
