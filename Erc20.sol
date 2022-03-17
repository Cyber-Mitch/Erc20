// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract Objective {

    address payable owner;
    string public name;
    string public symbol;
    uint8 public decimals; 
    uint256 public totalSupply;

    uint256 public tokenPrice;

    bool private runOnce;

    mapping(address => uint256) public balanceOf;

    event UpdatedPrice(uint256 indexed newPrice);
    event Transfer(address indexed sender, address indexed receiver, uint256 amount);
    event BoughtToken(address indexed buyer, uint256 amount);
    event OwnershipTransfer(address indexed newOwner);

  constructor() {
      owner = payable(address(msg.sender));
      name = "contract name";
      symbol = "CN";
      decimals = 18;

      setTotasuply();

  }

  modifier isOwner(){
      msg.sender == owner;
      _;
  }

  function setTotasuply() public isOwner {
      require(!runOnce, "This function can't be ran again");
      totalSupply = 1000000*1e18;
      balanceOf[owner] = totalSupply;
      runOnce = true;
      emit Transfer(address(0), owner, totalSupply);
  }


    function setTokenPrice(uint256 price) public virtual isOwner {
        tokenPrice = price * 1e18;
        emit UpdatedPrice(price);

    }

    function transfer(address send_to, uint256 amount) public returns (bool){
        require(balanceOf[msg.sender]>= amount, "you do not have enough token to complete this transaction");
        require(send_to != address(0), "you are not allowed to send to this address");
        require(msg.sender != address(0), "you can not receive token from this address");
        balanceOf[msg.sender]-= amount;
        balanceOf[send_to] += amount;
        emit Transfer(msg.sender, send_to, amount);
        return true;
    }

  function buyToken(address payable receiver) public payable virtual returns(bool){
      uint256 boughtToken = (tokenPrice * msg.value);
      require(balanceOf[owner]>= boughtToken, "there's not enough token in the smart contract");
      balanceOf[owner]-= boughtToken;
      balanceOf[receiver]+= boughtToken;
      emit BoughtToken(receiver, boughtToken);
      return true;
  }



    function withdrawEther()  external virtual isOwner returns (bool){
        owner.transfer(payable(address(this)).balance);
        return true;

    }


    function transferOwnership(address payable newOwner) external virtual isOwner returns (bool){
        owner = newOwner;
        transfer(owner, balanceOf[msg.sender]);
        emit OwnershipTransfer(newOwner);
        return true;
    }


}
