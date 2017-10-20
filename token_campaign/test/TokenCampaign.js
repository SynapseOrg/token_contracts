const BigNumber = web3.BigNumber

var TokenCampaign = artifacts.require("TokenCampaign");

contract("TokenCampaign", function(accounts) {

  var owner = accounts[0];
  var user1 = accounts[1];
  var user2 = accounts[2];
  var user3 = accounts[3];

  var tx_amount = 1000000000000000000; // 1 ether
  var cap = 1;
  var wei_rate = 1;
  var token_rate = 100;
  var minimum_purchase=1;

  it('creates a contract', async function() {
    const contract = await TokenCampaign.deployed();
    await contract.createCampaign("Test 1", cap, wei_rate, token_rate, minimum_purchase);
  });

  it('checks the number of contracts', async function() {
    const contract = await TokenCampaign.deployed();
    const num_campaigns = await contract.numCampaigns();
    assert.equal(num_campaigns, 1, "has the correct number");
  });

  /*
  it('checks the wei rate', async function() {
    const contract = await TokenCampaign.deployed();
    const rate = await contract.getWeiRate(1, 100);
    assert.equal(rate, wei_rate, 'has the correct wei rate');
  });

  it('checks the token rate', async function() {
    const contract = await TokenCampaign.deployed();
    const rate = await contract.getTokenRate(1, 1);
    assert.equal(rate, token_rate, 'has the correct wei rate');
  });
  */

  it('gets the current contract balance of 0', async function() {
    const contract = await TokenCampaign.deployed();
    const my_balance = await contract.getContractBalance();
    assert.equal(my_balance, 0, "has zero for a balance");
  });

  it('unpauses the state of the campaign', async function() {
    const contract = await TokenCampaign.deployed();
    await contract.unpauseEverything();
  });

  it('checks for the unpaused state', async function() {
    const contract = await TokenCampaign.deployed();
    const my_pause = await contract.isPaused();
    assert.equal(my_pause, false, "is unpaused.");
  });

  it('sends some ether to the contract', async function() {
    const contract = await TokenCampaign.deployed();
    await contract.send(tx_amount);
  });

  it('checks the balance reflect the change in transfer', async function() {
    const contract = await TokenCampaign.deployed();
    const my_balance = await contract.getContractBalance();
    assert.equal(my_balance, tx_amount, "has the correct contract balance");
  });

  it('checks the balance of the sender', async function() {
    const contract = await TokenCampaign.deployed();
    const my_balance = await contract.getBalance(owner);
    assert.equal(my_balance, tx_amount * token_rate, "has the correct account balance");
  });


  it('withdraws money to the owner of the contract', async function() {
    const prev_balance = web3.eth.getBalance(owner).toString();
    const contract = await TokenCampaign.deployed();
    await contract.withdraw(tx_amount);
    var new_balance = web3.eth.getBalance(owner).toString();
    assert.isAbove(new_balance, prev_balance, "is wealthier than before");
  });

  it('checks the final balance of the contract', async function() {
    const contract = await TokenCampaign.deployed();
    const my_balance = await contract.getContractBalance();
    assert.equal(my_balance, 0, "is zero contract balance");
  });

  // Secondary (non-owner) accounts


  /*

  it('checks balance for secondary accounts.', async function() {
    console.log("Checking secondary accounts.");
    var balance = web3.eth.getBalance(user1).toString();
    console.log(balance);
  });

  it('checks send for secondary accounts.', async function() {
    const contract = await TokenCampaign.deployed();
    console.log([user1, tx_amount]);
    await contract.send({from: user1, value: tx_amount.String()});
  });

  it('checks for the balance from user1', async function() {
    const contract = await TokenCampaign.deployed();
    const my_balance = await contract.getBalance({from: user1, value: user1});

    console.log(my_balance);

    assert.equal(my_balance, tx_amount, 'has the correct balance');
  });

  it('checks balance for secondary accounts.', async function() {
    var balance = web3.eth.getBalance(user1).toString();
    console.log(balance);
  });

  it('checks secondary accounts is not the owner', async function() {
    const contract = await TokenCampaign.deployed();
    const my_account = await contract.owner();

    assert.equal(owner, my_account, 'is the real owner');
  });


  */

});















