//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
//this contract allows users to claim an airdrop of ERC20 tokens
//through a merkle proof and a signature from the account owner

// The contract stores only the Merkle root which is a single hash 
//and it is calculated off-chain with the help of all the leaf nodes
// Each leaf node is the hash of the data we want 
//to store (in this case an address and an amount)
// The Merkle root is a single hash that represents the entire tree
// The user provides (in the transaction):
// Their leaf hash (example: keccak256(addr3) or 
//keccak256(abi.encodePacked(addr3, amount)) if amounts are included).
// The Merkle proof = an array of the sibling hashes needed to climb 
//from their leaf all the way to the root.



import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";



/**
 * @title Merkle Airdrop - Airdrop tokens to users who can prove they are in a merkle tree
 * @author Jeeshan Sheikh
 */

contract MerkleAirdrop is EIP712  {
    //some list of addresses
    //allow someone in the list to clain ERC20 tokens
   //we cannot use looping to check if an address is a part of a large list of
   //addresses so we use Merkle proofs

    using ECDSA for bytes32;
    using SafeERC20 for IERC20; // Prevent sending tokens to recipients who can’t receive
    //this means that the functions of the library SafeERC20 can only
    //be used on IERC20 variables

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    IERC20 private immutable i_airdropToken;
    bytes32 private immutable i_merkleRoot;

    //mappings
    //to keep track of users who have claimed
    mapping(address => bool) private s_hasClaimed;

    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account,uint256 amount)");

    // define the message hash struct
    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    event Claimed(address account, uint256 amount);
    event MerkleRootUpdated(bytes32 newMerkleRoot);

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("Merkle Airdrop", "1.0.0") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }



    //claim the airdrop using a signature from the account owner
   function claim external( //this allows other people to claim on behalf of the account owner
        address account, //we can i/p the address of the account we want to claim for therefore we need the signature to verify that the account owner has authorized this or not
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) //using the account address and the amount we create the leaf node
        external
    {
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        // Verify the signature
        if (!_isValidSignature(account, getMessage(account, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
        }

        // Verify t he merkle proof
        // calculate the leaf node hash

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        //hashing it twice while using Merkleproofs
        //it is a standard procedure
        // verify the merkle proof
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
    //MerkleProof.verify is the main function here that handles everything
            revert MerkleAirdrop__InvalidProof();
        }

        s_hasClaimed[account] = true; // prevent users claiming more than once and draining the contract
        emit Claimed(account, amount);
        // transfer the tokens
        i_airdropToken.safeTransfer(account, amount);
    }


      /*//////////////////////////////////////////////////////////////
                             VIEW AND PURE
    //////////////////////////////////////////////////////////////*/
    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }

    /*//////////////////////////////////////////////////////////////
                             INTERNAL
    //////////////////////////////////////////////////////////////*/

    // verify whether the recovered signer is the expected signer/the account to airdrop tokens for
    function _isValidSignature(
        address signer,
        bytes32 digest, //digest is the hashed message which tells that the signer has approved someone to claim the airdrop on their behalf
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) //v,r,s are components of a signature
    //signature is hashed combination of data(in this case approving someone to claim airdrop) and private key of the signer
    // v,r,s are the components of the signature that are used to verify the signature
        internal
        pure
        returns (bool)
    {
        // could also use SignatureChecker.isValidSignatureNow(signer, digest, signature)
        (
            address actualSigner,
            /*ECDSA.RecoverError recoverError*/
            // ECDSA is used for generating public and private keys
            //for creating and verifying signatures
            ,
            /*bytes32 signatureLength*/
        ) = ECDSA.tryRecover(digest, _v, _r, _s);
        //here because of using ECDSA zero address check has already been done
        return (actualSigner == signer);
    }
    function getMessage(address account, uint256 amount) public view returns (bytes32) {
       //it returns the digest
        return
            _hashTypedDataV4( //this function is from the EIP712 contract and it returns the hash of the fully encoded EIP712 message
                keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim(account , amount)))
            );
    }

}