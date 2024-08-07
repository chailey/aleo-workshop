program token_3349.aleo {
    mapping account: address => u64;
    // The `Token` record datatype.
    record Token {
        // The token owner.
        owner: address,
        // The token amount.
        amount: u64,
    }

    // The function `mint_public` issues the specified token amount for the token receiver publicly on the network.
    transition mint_public(public receiver: address, public amount: u64) {
        // Mint the tokens publicly by invoking the computation on-chain.
        return then finalize(receiver, amount);
    }

    finalize mint_public(public receiver: address, public amount: u64) {
        // Increments `account[receiver]` by `amount`.
        // If `account[receiver]` does not exist, it will be created.
        // If `account[receiver] + amount` overflows, `mint_public` is reverted.
        let receiver_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
        Mapping::set(account, receiver, receiver_amount + amount);
    }

    transition transfer_public(public receiver: address, public amount: u64) {
        // Transfer the tokens publicly, by invoking the computation on-chain.
        return then finalize(self.caller, receiver, amount);
    }

    finalize transfer_public(public sender: address, public receiver: address, public amount: u64) {
        // Decrements `account[sender]` by `amount`.
        // If `account[sender]` does not exist, it will be created.
        // If `account[sender] - amount` underflows, `transfer_public` is reverted.
        let sender_amount: u64 = Mapping::get_or_use(account, sender, 0u64);
        Mapping::set(account, sender, sender_amount - amount);

        // Increments `account[receiver]` by `amount`.
        // If `account[receiver]` does not exist, it will be created.
        // If `account[receiver] + amount` overflows, `transfer_public` is reverted.
        let receiver_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
        Mapping::set(account, receiver, receiver_amount + amount);
    }

    // The `mint` function initializes a new record with the
    // specified number of tokens assigned to the caller.
    transition mint(amount: u64) -> Token {
        return Token {
            owner: self.caller,
            amount: amount,
        };
    }

    transition transfer(r0: Token, r1: address, r2: u64) ->(Token, Token) {

        // Checks the given token record has sufficient balance.
        // This `sub` operation is safe, and the proof will fail
        // if an underflow occurs. The output register `r3` holds
        // the change amount to be returned to the sender.
        let r3 : u64 = r0.amount.sub(r2);

        // Produces a token record for the specified receiver.
        let new1 : Token = Token {
            owner: r1,
            amount: r2
        };

        // Produces a token record with the change amount for the sender.
        let new2 : Token = Token {
            owner: r0.owner,
            amount: r3
        };

        // Output the receiver's record.
       return ( new1, new2);
        // Output the sender's change record.
    }

    
    transition balance_of(owner_balance: Token) -> u64 {
        return (owner_balance.amount);
    }

}