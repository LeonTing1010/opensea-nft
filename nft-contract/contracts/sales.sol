// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
//import "./nft.sol";

contract Sales is PullPayment, Ownable ,AccessControl {

     // Create a new role identifier for the minter role
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public constant TOTAL_SUPPLY = 10_000;
    uint256 public constant MINT_PRICE = 0.01 ether;

    address public nftAddress;

    uint256 public openingTime;// crowdsale opening time
    uint256 public closingTime;// crowdsale closing time

    using Counters for Counters.Counter;
    Counters.Counter private currentTokenId;

      /**
   * @dev Reverts if not in crowdsale time range.
   */
    modifier onlyWhileOpen {
        // solium-disable-next-line security/no-block-members
        require(block.timestamp >= openingTime && block.timestamp <= closingTime);
        _;
    }
   constructor() {
      // Grant the contract deployer the default admin role: it will be able to grant and revoke any roles
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setNftAddress(address _nftAddress) external {
        nftAddress = _nftAddress;
    }

    function setOpeningTime(uint256 _openingTime) external {
        openingTime = _openingTime;
    }

    function setClosingTime(uint256 _closingTime) external {
        closingTime = _closingTime;
    }

    function sale(address _recipient) public payable onlyRole(MINTER_ROLE) onlyWhileOpen returns (uint256) {
        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        //NFT nft = NFT(nftAddress);
        //uint256 tokenId = nft.current();
        require(newItemId <= TOTAL_SUPPLY, "Max supply reached");
        require(msg.value >= MINT_PRICE, "Transaction value did not greater than the mint price");
        (bool success,  ) = nftAddress.call(abi.encodeWithSignature("mintTo(address)",_recipient));
        require(success,"Mining failed");
        //uint256 newItemId = nft.mintTo(_recipient);

        _asyncTransfer(owner(), msg.value);
        return newItemId;
    }

    /// @dev Overridden in order to make it an onlyOwner function
    function withdrawPayments(address payable payee)
        public
        virtual
        override
        onlyOwner
    {
        super.withdrawPayments(payee);
    }
}
