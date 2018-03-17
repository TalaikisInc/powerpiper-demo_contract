const PowerPiperCrowdsale = artifacts.require('./PowerPiperCrowdsale.sol')
const PowerPiperToken = artifacts.require('./PowerPiperToken.sol')
const RefundVault = artifacts.require('./RefundVault.sol')

import ether from './helpers/ether'
import { advanceBlock } from './helpers/advanceToBlock'
import { increaseTimeTo, duration } from './helpers/increaseTime'
import latestTime from './helpers/latestTime'
import EVMRevert from './helpers/EVMRevert'

const BigNumber = web3.BigNumber

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should()

contract('PowerPiperCrowdsale', function ([owner, wallet, investor, purchaser]) {
  const rate = new BigNumber(3000)
  const cap = ether(1000)

  before(async function () {
    // Advance to the next block to correctly read time in the solidity "now" function interpreted by testrpc
    await advanceBlock()
  })

  beforeEach(async function () {
    this.openingTime = latestTime() + duration.weeks(1)
    this.closingTime = this.openingTime + duration.weeks(1)
    this.afterClosingTime = this.closingTime + duration.seconds(1)

    this.token = await PowerPiperToken.new({ from: owner })
    this.vault = await RefundVault.new(wallet, { from: owner })
    this.crowdsale = await PowerPiperCrowdsale.new(
      this.openingTime, this.closingTime, rate, wallet, this.token.address, cap
    )
    await this.token.transferOwnership(this.crowdsale.address)
    await this.vault.transferOwnership(this.crowdsale.address)
  })

  it('should create crowdsale with correct parameters', async function () {
    this.crowdsale.should.exist
    this.token.should.exist

    const openingTime = await this.crowdsale.openingTime()
    const closingTime = await this.crowdsale.closingTime()
    const rate = await this.crowdsale.rate()
    const walletAddress = await this.crowdsale.wallet()
    const cap = await this.crowdsale.cap()

    openingTime.should.be.bignumber.equal(this.openingTime)
    closingTime.should.be.bignumber.equal(this.closingTime)
    rate.should.be.bignumber.equal(rate)
    walletAddress.should.be.equal(wallet)
    cap.should.be.bignumber.equal(cap)
  })

  it('should not accept payments before start', async function () {
    await this.crowdsale.send(ether(1)).should.be.rejectedWith(EVMRevert)
    await this.crowdsale.buyTokens(investor, { from: investor, value: ether(1) }).should.be.rejectedWith(EVMRevert)
  })

  it('should accept payments during the sale', async function () {
    const investmentAmount = ether(1.3)
    const expectedTokenAmount = rate.mul(investmentAmount)

    await increaseTimeTo(this.openingTime)
    await this.crowdsale.buyTokens(investor, { value: investmentAmount, from: investor }).should.be.fulfilled

    (await this.token.balanceOf(investor)).should.be.bignumber.equal(expectedTokenAmount)
    (await this.token.totalSupply()).should.be.bignumber.equal(expectedTokenAmount)
  })

  it('should reject payments after end', async function () {
    await increaseTimeTo(this.afterEnd)
    await this.crowdsale.send(ether(1)).should.be.rejectedWith(EVMRevert)
    await this.crowdsale.buyTokens(investor, { value: ether(1), from: investor }).should.be.rejectedWith(EVMRevert)
  })

  it('should reject payments over cap', async function () {
    await increaseTimeTo(this.openingTime)
    await this.crowdsale.send(cap)
    await this.crowdsale.send(1).should.be.rejectedWith(EVMRevert)
  })

  it('should allow finalization and transfer funds to wallet if the cap is reached', async function () {
    await increaseTimeTo(this.openingTime)
    await this.crowdsale.send(cap)

    const beforeFinalization = web3.eth.getBalance(wallet)
    await increaseTimeTo(this.afterClosingTime)
    await this.crowdsale.finalize({ from: owner })
    const afterFinalization = web3.eth.getBalance(wallet)

    afterFinalization.minus(beforeFinalization).should.be.bignumber.equal(GOAL)
  })
  
  /* Crowdsale
  
  describe('high-level purchase', function () {
    it('should log purchase', async function () {
      const { logs } = await this.crowdsale.sendTransaction({ value: value, from: investor });
      const event = logs.find(e => e.event === 'TokenPurchase');
      should.exist(event);
      event.args.purchaser.should.equal(investor);
      event.args.beneficiary.should.equal(investor);
      event.args.value.should.be.bignumber.equal(value);
      event.args.amount.should.be.bignumber.equal(expectedTokenAmount);
    });

    it('should assign tokens to sender', async function () {
      await this.crowdsale.sendTransaction({ value: value, from: investor });
      let balance = await this.token.balanceOf(investor);
      balance.should.be.bignumber.equal(expectedTokenAmount);
    });

    it('should forward funds to wallet', async function () {
      const pre = web3.eth.getBalance(wallet);
      await this.crowdsale.sendTransaction({ value, from: investor });
      const post = web3.eth.getBalance(wallet);
      post.minus(pre).should.be.bignumber.equal(value);
    });
  });

  describe('low-level purchase', function () {
    it('should log purchase', async function () {
      const { logs } = await this.crowdsale.buyTokens(investor, { value: value, from: purchaser });
      const event = logs.find(e => e.event === 'TokenPurchase');
      should.exist(event);
      event.args.purchaser.should.equal(purchaser);
      event.args.beneficiary.should.equal(investor);
      event.args.value.should.be.bignumber.equal(value);
      event.args.amount.should.be.bignumber.equal(expectedTokenAmount);
    });

    it('should assign tokens to beneficiary', async function () {
      await this.crowdsale.buyTokens(investor, { value, from: purchaser });
      const balance = await this.token.balanceOf(investor);
      balance.should.be.bignumber.equal(expectedTokenAmount);
    });

    it('should forward funds to wallet', async function () {
      const pre = web3.eth.getBalance(wallet);
      await this.crowdsale.buyTokens(investor, { value, from: purchaser });
      const post = web3.eth.getBalance(wallet);
      post.minus(pre).should.be.bignumber.equal(value);
    });
  });
  */

  /* Capped
  describe('creating a valid crowdsale', function () {
    it('should fail with zero cap', async function () {
      await CappedCrowdsale.new(rate, wallet, 0, this.token.address).should.be.rejectedWith(EVMRevert);
    });
  });

  describe('accepting payments', function () {
    it('should accept payments within cap', async function () {
      await this.crowdsale.send(cap.minus(lessThanCap)).should.be.fulfilled;
      await this.crowdsale.send(lessThanCap).should.be.fulfilled;
    });

    it('should reject payments outside cap', async function () {
      await this.crowdsale.send(cap);
      await this.crowdsale.send(1).should.be.rejectedWith(EVMRevert);
    });

    it('should reject payments that exceed cap', async function () {
      await this.crowdsale.send(cap.plus(1)).should.be.rejectedWith(EVMRevert);
    });
  });

  describe('ending', function () {
    it('should not reach cap if sent under cap', async function () {
      let capReached = await this.crowdsale.capReached();
      capReached.should.equal(false);
      await this.crowdsale.send(lessThanCap);
      capReached = await this.crowdsale.capReached();
      capReached.should.equal(false);
    });

    it('should not reach cap if sent just under cap', async function () {
      await this.crowdsale.send(cap.minus(1));
      let capReached = await this.crowdsale.capReached();
      capReached.should.equal(false);
    });

    it('should reach cap if cap sent', async function () {
      await this.crowdsale.send(cap);
      let capReached = await this.crowdsale.capReached();
      capReached.should.equal(true);
    });
  });
  */

  it('should be token owner', async function () {
    const owner = await this.token.owner()
    owner.should.equal(this.crowdsale.address)
  })

  describe('high-level purchase', function () {
    const value = ether(42)
    const expectedTokenAmount = rate.mul(value)

    it('should log purchase', async function () {
      const { logs } = await this.crowdsale.sendTransaction({ value: value, from: investor, gas: 299999 })
      const event = logs.find(e => e.event === 'TokenPurchase')
      should.exist(event)
      event.args.purchaser.should.equal(investor)
      event.args.beneficiary.should.equal(investor)
      event.args.value.should.be.bignumber.equal(value)
      event.args.amount.should.be.bignumber.equal(expectedTokenAmount)
    })

    it('should assign tokens to sender', async function () {
      await this.crowdsale.sendTransaction({ value: value, from: investor, gas: 299999 })
      let balance = await this.token.balanceOf(investor)
      balance.should.be.bignumber.equal(expectedTokenAmount)
    })

    it('should forward funds to wallet', async function () {
      const pre = web3.eth.getBalance(wallet)
      await this.crowdsale.sendTransaction({ value, from: investor, gas: 299999 })
      const post = web3.eth.getBalance(wallet)
      post.minus(pre).should.be.bignumber.equal(value)
    })
  })

  /* Timed
  it('should be ended only after end', async function () {
    let ended = await this.crowdsale.hasClosed();
    ended.should.equal(false);
    await increaseTimeTo(this.afterClosingTime);
    ended = await this.crowdsale.hasClosed();
    ended.should.equal(true);
  });

  describe('accepting payments', function () {
    it('should reject payments before start', async function () {
      await this.crowdsale.send(value).should.be.rejectedWith(EVMRevert);
      await this.crowdsale.buyTokens(investor, { from: purchaser, value: value }).should.be.rejectedWith(EVMRevert);
    });

    it('should accept payments after start', async function () {
      await increaseTimeTo(this.openingTime);
      await this.crowdsale.send(value).should.be.fulfilled;
      await this.crowdsale.buyTokens(investor, { value: value, from: purchaser }).should.be.fulfilled;
    });
  });
  */

  /*it('should have a symbol', async function () {
    let symbol = await token.symbol()
    assert.equal(symbol, 'PWP')
  })*/

  /*it('has an owner', async function () {
    const fundRaiseOwner = await PowerPiperCrowdsale.owner()
    fundRaiseOwner.should.be.equal(owner)
  })

  it('accepts funds', async function () {
    await PowerPiperCrowdsale.sendTransaction({ value: 1e+18, from: purchaser })

    const fundRaiseAddress = await PowerPiperCrowdsale.address
    web3.eth.getBalance(fundRaiseAddress).should.be.bignumber.equal(1e+18)
  })

  it('is able to pause and unpause fund activity', async function () {
    await PowerPiperCrowdsale.pause()
    PowerPiperCrowdsale.sendTransaction({ value: 1e+18, from: purchaser }).should.be.rejectedWith(EVMThrow)

    const fundRaiseAddress = await fundRaise.address
    web3.eth.getBalance(fundRaiseAddress).should.be.bignumber.equal(0)

    // unpausing it
    await PowerPiperCrowdsale.unpause()
    await PowerPiperCrowdsale.sendTransaction({ value: 1e+18, from: purchaser })
    web3.eth.getBalance(fundRaiseAddress).should.be.bignumber.equal(1e+18)
  })

  it('permits owner to receive funds', async function () {
    await PowerPiperCrowdsale.sendTransaction({ value: 1e+18, from: purchaser })
    const ownerBalanceBeforeRemovingFunds = web3.eth.balanceOf(owner).toNumber()

    const fundRaiseAddress = await PowerPiperCrowdsale.address
    web3.eth.getBalance(fundRaiseAddress).should.be.bignumber.equal(1e+18)

    // removing funds
    await PowerPiperCrowdsale.removeFunds()
    web3.eth.getBalance(fundRaiseAddress).should.be.bignumber.equal(0)
    web3.eth.getBalance(owner).should.be.bignumber.above(ownerBalanceBeforeRemovingFunds)
  })*/
})
