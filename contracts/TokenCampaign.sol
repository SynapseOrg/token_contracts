pragma solidity ^0.4.11;

// Paused is true by default
// When testing, turn paused off
contract TokenCampaign {

  string public title = "Synapse (SYN™)  Token Campaign";

  address owner;

  uint256 public numCampaigns;
  uint256 public currentCampaignID;
  bool paused = true; // Campaign starts off as paused
  uint256 contractBalance;
  uint256 totalRaised;

  struct Campaign {
    uint256 cap;
    uint256 tokens_per_wei;
    uint256 wei_minimum;
    uint256 totalBalance;
  }

  mapping (address => uint256) balances; // balances of tokens (SYN)
  mapping (uint256 => Campaign) campaigns;

  event Event(string _msg, uint256 _value);
  event Purchase(address _buyer, uint256 _value);

  /* modifiers */
  modifier onlyOwner {
    if(msg.sender !=  owner) {
      revert();
    } else {
      _;
    }
  }

  modifier pausable {
    if(paused == true) {
      revert();
    } else {
      _;
    }
  }


  function TokenCampaign() {
    owner = msg.sender;
  }


  // Create a campaign
  function createCampaign(uint256 _cap,
                          uint256 _tokens_per_wei,
                          uint256 _minimum
                          )
                          public
                          onlyOwner {
    campaigns[numCampaigns] = Campaign(_cap, _tokens_per_wei, _minimum, 0);
    numCampaigns = numCampaigns + 1;
  }

  // Returns details for campaign with specific ID
  function getCampaign(uint256 _campaignID)
    public
    constant
    returns (
      uint256 campaignID,
      uint256 cap,
      uint256 tokens_per_wei,
      uint256 wei_minimum) {
    var c = campaigns[_campaignID];
    return (_campaignID, c.cap, c.tokens_per_wei, c.wei_minimum);
  }

  // Returns details for current campaign
  function getCurrentCampaign() 
    public
    constant
    returns (uint256 campaignID,
             uint256 cap,
	     uint256 tokens_per_wei,
             uint256 wei_minimum) {
    var c = campaigns[currentCampaignID];
    return (currentCampaignID, c.cap, c.tokens_per_wei, c.wei_minimum);
  }

  // Sets the current campaign via ID
  function setCurrentCampaign(uint256 _campaignID) public onlyOwner {
    currentCampaignID = _campaignID;
  }

  // Update campaign details
  function updateCampaignDetails(uint256 _campaignID,
                                 uint256 _cap,
                                 uint256 _tokens_per_wei,
                                 uint256 _wei_minimum)
                                 public
                                 onlyOwner {
    var c = campaigns[_campaignID];
    c.cap = _cap;
    c.tokens_per_wei = _tokens_per_wei;
    c.wei_minimum = _wei_minimum;
  }

  // Get total current balance on contract
  function getContractBalance() public constant returns (uint256) {
    return contractBalance;
  }

  function getTotalRaised() public constant onlyOwner returns (uint256) {
    return totalRaised;
  }

  // Get balance of account
  function getBalance(address _account) public constant returns (uint256) {
    return balances[_account];
  }

  // Pause all campaigns
  function pauseEverything() public onlyOwner {
    paused = true;
    Event("Campaign paused.", 0);
  }

  // Unpause all campaigns
  function unpauseEverything() public onlyOwner {
    paused = false;
    Event("Campaign unpaused.", 0);
  }

  function isPaused() public constant onlyOwner returns (bool) {
    if(paused == true) {
      return true;
    } else {
      return false;
    }
  }

  // Withdraw ETH to owners address
  // Should be public, onlyOwner
  function withdraw(uint256 _amount) public onlyOwner {
    owner.transfer(_amount);
    contractBalance = contractBalance - _amount;
  }

  /* Buyers functions */

  // Input WEI and get token conversion
  function getCurrentTokenRate(uint256 query_wei) public constant returns (uint256) {
    return getTokenRate(currentCampaignID, query_wei);
  }

  function getTokenRate(uint256 _campaignID, uint256 query_wei) public constant returns (uint256) {
    var c = campaigns[_campaignID];
    uint256 query_token = query_wei * c.tokens_per_wei;
    return query_token;
  }

  function getCurrentWeiRate(uint256 query_token) public constant returns (uint256) {
    return getWeiRate(currentCampaignID, query_token);
  }

  function getWeiRate(uint256 _campaignID, uint256 query_token) public constant returns (uint256) {
    var c = campaigns[_campaignID];
    uint256 query_wei = query_token / c.tokens_per_wei;
    // Make sure query_wei gives an integer amount of tokens.
    if (query_wei * c.tokens_per_wei != query_token) {
        Event("Wei amount does not buy an integer amount of tokens.", query_wei);
        revert();
    }
    return query_wei;
  }

  function buyTokens() public payable pausable {
    uint256 token_value = getCurrentTokenRate(msg.value);

    balances[msg.sender] = balances[msg.sender] + token_value;
    contractBalance = contractBalance + msg.value;
    totalRaised = totalRaised + msg.value;
    Purchase(msg.sender, msg.value); // emit an event
  }

  function refund(address _address, uint256 _token_amount) public onlyOwner {
    uint256 wei_value = getWeiRate(currentCampaignID, _token_amount);
    if(_token_amount > balances[_address]) {
      Event("Can't refund more than balance.", _token_amount);
      revert();
    } else {
      _address.transfer(wei_value); // throws on failure
      balances[_address] = balances[_address] - _token_amount;
      contractBalance = contractBalance - wei_value;
    }
  }

  // Take WEI sent and update balance based on current campaign conversion
  function () payable {
    buyTokens();
  }
}
