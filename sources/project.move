module MyModule::RoyaltyDistribution {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing royalty shares for an artist.
    struct Royalty has store, key {
        artist: address,
        share: u64,       // Percentage of the total revenue (e.g., 20 means 20%)
        total_earned: u64, // Total royalties earned by the artist
    }

    /// Function to create a royalty agreement for an artist.
    public fun create_royalty(creator: &signer, artist: address, share: u64) {
        let royalty = Royalty {
            artist,
            share,
            total_earned: 0,
        };
        move_to(creator, royalty);
    }

    /// Function to distribute royalties based on sales or usage data.
    public fun distribute_royalty(payer: &signer, creator_address: address, total_sale: u64) acquires Royalty {
        let royalty = borrow_global_mut<Royalty>(creator_address);
        
        // Calculate the artist's share from the total sale
        let artist_earnings = (total_sale * royalty.share) / 100;

        // Payer transfers the calculated royalty to the artist
        let payment = coin::withdraw<AptosCoin>(payer, artist_earnings);
        coin::deposit<AptosCoin>(royalty.artist, payment);

        // Update the total royalties earned by the artist
        royalty.total_earned = royalty.total_earned + artist_earnings;
    }
}
