# 📜 Sphinx Contracts Overview

Welcome to the **Sphinx Contracts** repository! This project contains smart contracts for the Sphinx protocol, centered around decentralized knowledge sharing and incentivized response submission. The key components of this system include:

- **QUESTION Contract** 🧠
- **$PHI Token** 🪙

## 🚀 Introduction

Sphinx aims to build a decentralized platform where users can participate in knowledge exchange by answering important questions. The responses are recorded on the blockchain, ensuring transparency and accountability. Participants are rewarded with $PHI tokens for their valuable contributions.

## 📋 QUESTION Contract

The **QUESTION Contract** handles the following core functionalities:
- **Initialize a Question**: Admin (owner) initializes a new question with metadata stored on IPFS. The question is tagged with a unique `question-id` and can only be answered while it remains "open."
- **Submit a Response**: Users submit their responses by uploading them to IPFS and providing the IPFS CID (Content Identifier). The contract ensures only one response per user and charges a submission fee in STX.
- **Close the Question**: Once the admin deems the question closed, no more responses are allowed.
- **Manage STX Pool**: The contract also handles the contributions to the question pool and manages the funds stored in the contract, including transfers.

### Core Functions:

1. **initialize-question()**:
   Initializes the question in an open state, along with its metadata from IPFS.

2. **submit-response(ipfs-cid)**:
   Allows users to submit their response. The response is associated with the user's principal address and stored on IPFS.

3. **close-question()**:
   Admin-only function to close the question and prevent further responses.

4. **contribute-to-pool(amount)**:
   Users can contribute additional STX to the question pool for rewards and funding future questions.

5. **get-question-details()** (Read-only):
   Retrieves the current question's metadata and its status (open/closed).

6. **get-response(user)** (Read-only):
   Retrieves the IPFS CID for the response submitted by a specific user.

## 💸 $PHI Token

The **$PHI token** is the native utility token for the Sphinx ecosystem. It is used to reward users who participate in the platform, whether by answering questions, contributing to the question pool, or interacting with the community. 

- **Symbol**: $PHI 🪙
- **Use Case**: Rewards for submitting responses, staking for governance, and contributing to future questions.
- **Tokenomics**: $PHI tokens are distributed to users who submit valid responses. In future versions, staking and governance features will be incorporated.

## 💻 How to Interact with the Contracts

To interact with these contracts, follow these steps:

1. **Deploy the QUESTION Contract**:
   Deploy the contract on the Stacks blockchain using a Clarity smart contract deployment tool like [Clarinet](https://docs.hiro.so/get-started/clarinet).

2. **Submit Responses**:
   - Users can submit their responses by signing transactions with their Xverse or Hiro wallets.
   - The IPFS CID of the response is passed as an argument to the `submit-response` function.

3. **Earn Rewards**:
   Upon closing the question, $PHI tokens can be distributed to the top contributors based on their responses.

## 🌍 Future Plans

- **Decentralized Governance**: $PHI holders will be able to vote on future questions, changes to the protocol, and community initiatives.

## 📖 Documentation

- **Contracts**: You can find the smart contract files in the `contracts/` directory.
- **Deployment**: Instructions for deployment and interaction with the Stacks blockchain are included in the `docs/` directory.

## 🤝 Contributing

We welcome contributions from the community! If you'd like to help improve Sphinx, please submit a pull request or open an issue in this repository.

---

🔗 **Official Website**: sphinx-brown.vercel.app
📦 **IPFS Gateway**: Hosted by [Pinata](https://pinata.cloud/).

> [Sphins Deployed Contracts](https://explorer.hiro.so/address/ST1Q1JNCJXBC4PF7JH17JDBS6GBP96SFBKJEEYBJD?chain=testnet)