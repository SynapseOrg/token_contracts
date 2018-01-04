pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TokenCampaign.sol";

contract TestTokenCampaign {

  // Use this converter: https://etherconverter.online/

  uint256 public initialBalance   = 50 ether; // Must be < 100 ether
  uint256 public tx_amount     = 1 ether; // 10 ether
  uint256 public refund_amount =  1 ether; // 1 ether

  uint256 public campaignID = 0;

  string campaign_name = "Test 1";
  uint256 campaign_cap = 1 ether;
  uint256 campaign_wei_value = 1 wei;
  uint256 campaign_token_value = 100;
  uint256 campaign_minimum = 10 wei;


  event Identify(address sender);
  event TokenRate(uint256 token_amount);
  event TokenAmount(uint256 value);
  event CompletedCampaign(bool result);
  event CampaignNumber(uint256 campaignNumber);

  // Global so every test can reference it
  TokenCampaign tkc = new TokenCampaign(); //ToKenCampaign -- local

  address DeployedTokenContract = DeployedAddresses.TokenCampaign();
  TokenCampaign tkd = TokenCampaign(DeployedTokenContract); //ToKenDeployed  -- remote

  function testCreateCampaign() {
    bool my_campaign = tkc.createCampaign(campaign_name,
                                          campaign_cap,
                                          campaign_wei_value,
                                          campaign_token_value,
                                          campaign_minimum);

    Assert.equal(my_campaign, true, "Campaign should be created");
  }

  function testCampaignNumber() {
    uint256 my_numCampaigns = tkc.numCampaigns();
    uint256 expectedCampaigns = 1;
    CampaignNumber(my_numCampaigns);
    Assert.equal(my_numCampaigns, expectedCampaigns, "Campaign count must equal 1");
  }


  function testInitialContractBalance() {
    uint256 initial_balance = tkc.getContractBalance();
    Assert.equal(initial_balance, 0, "Initial balance should be 0");
  }

  function testPauseEverything() {
    bool paused = tkc.pauseEverything();
    Assert.equal(paused, true, "Campaign should be unpaused");
  }


  function testUnpauseEverything() {
    bool paused = tkc.unpauseEverything();
    Assert.equal(paused, true, "Campaign should be unpaused");
  }

  function testIsUnpaused() {
    bool paused = tkc.isPaused();
    Assert.equal(paused, false, "Campaign should be unpaused");
  }

  function testSendContractBalance() {
    //Assert.isAbove(this.balance, tx_amount, "this.balance is above tx_amount");
    tkc.transfer(1 ether);

    //uint256 updated_balance = tkc.getContractBalance();
    //Assert.equal(updated_balance, tx_amount, "Updated balance should be 10 Ether");
  }

  function testCheckBuyerBalance() {
    uint256 my_balance = tkc.getBalance(msg.sender);
    Assert.equal(my_balance, tx_amount, "Balance should be tx_amount");
  }

  function testTokenRate() {
    uint256 my_tokens = tkc.getTokenRate(campaignID, campaign_wei_value);
    Assert.equal(my_tokens, campaign_token_value, "Token rate should equal token value");
  }

  function testWeiRate() {
    uint256 my_wei = tkc.getWeiRate(campaignID, campaign_token_value);
    Assert.equal(my_wei, campaign_wei_value, "Wei rate should equal wei value");
  }

  // refund 1 eth
  function testRefund() {

    bool my_refund = tkc.refund(msg.sender, refund_amount);

    Assert.equal(my_refund, true, "My refund should have been true");

    uint256 contract_balance = tkc.getContractBalance();
    uint256 expected_contract_balance = initialBalance - tx_amount + refund_amount;

    Assert.equal(contract_balance, expected_contract_balance, "Contract balance not updated after refund");
  }

  function testBalanceAfterContractRefund() {
    uint256 my_balance = tkc.getBalance(msg.sender);
    uint256 expected_balance = tx_amount + refund_amount;
    Assert.equal(my_balance, expected_balance, "My balance on the contract is not my expected balance");
  }

}


