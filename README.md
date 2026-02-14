#  Bagel Token Airdrop (Merkle Tree Based)

This project contains **smart contracts for a token airdrop system** where **Bagel Tokens** are distributed only to eligible users.  
Eligibility is verified using a **Merkle Tree**, and users can claim their tokens by submitting a valid **Merkle Proof**.

The main goal of this project was to learn how **large airdrops can be done efficiently on-chain** without storing thousands of addresses in smart contract storage.

---

##  What this project does

- Distributes **Bagel Tokens** via an airdrop
- Only addresses included in a **Merkle Tree** can claim tokens
- Users prove eligibility using **Merkle Proofs**
- Uses **OpenZeppelin’s MerkleProof library**
- Prevents double-claiming
- Gas-efficient and scalable

---

##  How the Airdrop Works

### 1. Off-chain Merkle Tree Creation
- A list of eligible user addresses (and amounts, if applicable) is created off-chain.
- A **Merkle Tree** is generated from this list.
- The **Merkle Root** is stored in the smart contract.

### 2. Claiming Tokens
- A user calls the `claim()` function on the contract.
- The user provides:
  - Their address
  - The amount they are eligible for (if required)
  - A valid **Merkle Proof**

### 3. Verification
- The contract uses **OpenZeppelin’s `MerkleProof`** library to verify:
  - The address exists in the Merkle Tree
  - The proof matches the stored Merkle Root

### 4. Token Distribution
- If the proof is valid and the user hasn’t claimed before:
  - Bagel Tokens are transferred to the user
- The claim is marked as completed to prevent reuse

---

##  Why Use a Merkle Tree?

Storing thousands of addresses on-chain is expensive.

Merkle Trees allow:
- Storing **only one hash (Merkle Root)** on-chain
- Users to prove eligibility with a short proof
- Massive gas savings
- Secure and verifiable claims

This approach is commonly used for **airdrops and allowlists**.

---

##  OpenZeppelin MerkleProof

This project uses **OpenZeppelin’s `MerkleProof` contract**, which provides:
- A safe and audited implementation
- Efficient proof verification
- Reduced risk of implementation bugs

---

##  Tech Stack

- **Solidity** – Smart contract language
- **EVM-compatible blockchain**
- **OpenZeppelin Contracts**
  - `MerkleProof`
  - `ERC20`
- **Foundry** – Development & testing

---

##  Important Parameters

- **Merkle Root**  
  The root hash of the Merkle Tree containing eligible addresses.

- **Bagel Token Address**  
  The ERC20 token being distributed.

- **Claim Tracking**  
  Mapping to ensure each address can claim only once.

---

##  Security Notes

- Uses OpenZeppelin’s audited libraries
- Prevents double-claims
- No storage of large address lists on-chain
- Users must provide valid Merkle proofs
- All eligibility checks are done on-chain

> ⚠️ Always verify Merkle Tree generation off-chain carefully, as incorrect tree construction can break claims.

---

##  Example Claim Flow

- User address is included in the Merkle Tree
- User generates a Merkle Proof off-chain
- User calls `claim()` with the proof
- Contract verifies the proof using `MerkleProof`
- Bagel Tokens are transferred to the user
  
---

##  Testing Ideas

- Test valid claims
- Test invalid proofs
- Test double-claim prevention
- Test incorrect amounts or addresses
- Test Merkle root updates (if supported)

---

## 📄 License

MIT License

---
