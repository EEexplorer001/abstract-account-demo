# About

1. Create an AA on Ethereum
2. Create an AA on zkSync
3. Deploy, and send a userOp / transaction through them
   1. Not going to send an AA to Ethereum
   2. But we will send an AA tx to zkSync

System contract: In zkSync, when you deploy a contract, it is governed by system contracts.

/**
 * Lifecycle of a type 113 (0x71) transaction
 * msg.sender is the bootloader system contract
 * 
 * Phase 1 Validation
 * 1. The user sends the txn to the "zkSync API Client" (light node)
 * 2. The zkSync API client checks to see the nonce is unique by querying the NonceHolder system contract
 * 3. The zkSync API client calls validateTransaction, which MUST update the nonce.
 * 4. The zkSync API client checks the nonce is updated
 * 5. The zkSync API client calls for payForTransaction, or prepareForPaymaster & validateAndPayForPaymasterTransaction.
 * 6. The zkSync API client verifies that the bootloader is paid.
 * 
 * You want each transaction from a given sender (account) to be uniquely identified (no two valid transactions with the same (sender, nonce) pair). If you allowed duplicates, someone could replay a transaction that was already included.
 * 
 * Phase 2 Execution
 * 7. The zkSync API client passes the validated transaction to the main node / sequencer 
 * 8. The sequencer calls executeTransaction
 * 9. If a paymaster was used, the postTransaction is called.
 * 
 */
 # for account-abstraction
 Used https://github.com/eth-infinitism/account-abstraction v0.7.0 since v0.8.0 cannot compile in foundry zkSync: Error: LLVM IR generator: 2633:17 The `EXTCODECOPY` instruction is not supported