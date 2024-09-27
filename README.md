# Wizard of Rhiz Bot

A Discord bot for tracking and managing positions across various protocols.

## Features

- Check balances for supported protocols with detailed pool and position information
- Estimate rewards for positions with improved accuracy
- Automatic notifications for new rewards
- In-range/out-of-range position notifications with real-time status updates
- Detailed pool and position calculations, including:
  - Current pool price and liquidity
  - Position-specific token amounts
  - Tick range and current tick information
- Frequent updates (every 2 minutes)

## Supported Protocols

- Nile
- Nuri
- Ra
- Cleo
- Pharaoh
- Ramses

## Setup

1. Clone the repository:
   ```
   git clone https://github.com/chunky-metro/wizard-of-rhiz-bot.git
   cd wizard-of-rhiz-bot
   ```

2. Install dependencies:
   ```
   bundle install
   ```

3. Set up environment variables:
   Create a `.env` file in the root directory and add the following:
   ```
   DISCORD_BOT_TOKEN=your_discord_bot_token
   API_BASE_URL=your_api_base_url
   ```

4. Set up the database:
   ```
   rake db:create
   rake db:migrate
   ```

5. Ensure the `eth` gem is properly configured for interacting with the blockchain. You may need to set up additional environment variables for RPC URLs and contract addresses.

## Database Migrations

If you're updating an existing installation, make sure to run the latest migration:

```
rake db:migrate
```

This will add the `in_range` field to the positions table, which is necessary for the new in-range/out-of-range functionality.

## Running the Bot

To start the bot, run:

```
ruby lib/wizard/of/rhiz/bot.rb
```

## Usage

In Discord, you can use the following commands:

- `!balance [protocol]` - Check your balance for a specific protocol. This now includes detailed information such as:
  - Token amounts for each position
  - Current pool price and liquidity
  - Tick range and current tick
  - In-range/out-of-range status
- `!rewards [protocol]` - Check your estimated rewards for a specific protocol. The rewards calculation now takes into account:
  - Current pool price
  - Pool liquidity
  - Position-specific details for more accurate estimation
- `!help` - Show the help message with available commands

The bot will automatically send notifications for:
- New rewards (when estimated rewards exceed a certain threshold)
- Position status changes (in-range/out-of-range) as they occur

## Development

To run tests:

```
rspec
```

To run the linter:

```
standardrb
```

## API Endpoints

The bot interacts with a backend API. Here are some of the key endpoints:

- `GET /api/positions/status` - Get the current status of a position
- `PUT /api/positions/:id` - Update the status of a position
- `GET /api/pools/details` - Get detailed information about a pool
- `GET /api/positions/from_chain` - Get position details from the blockchain

For a full list of endpoints and their usage, refer to the `api.rb` file.

## Troubleshooting

- If you're not receiving notifications, ensure that your Discord privacy settings allow direct messages from bot users.
- If the bot is not responding to commands, check the console output for any error messages and ensure the Discord token is correctly set in the `.env` file.
- For issues with reward calculations or position status, verify that the blockchain RPC URLs are correctly configured and accessible.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a pull request

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.

## Notes

- The bot checks for updates every 2 minutes. This frequency can be adjusted in the `setup_notification_system` method in `bot.rb`.
- The `in_range` field in the Position model is used to support the new in-range/out-of-range functionality.
- The rewards calculation and pool details now use more accurate implementations based on current blockchain data.
- Automatic position status updates ensure that users always have the most up-to-date information about their positions.
