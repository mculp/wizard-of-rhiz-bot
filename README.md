# Wizard of Rhiz Bot

A Discord bot for tracking and managing positions across various protocols.

## Features

- Check balances for supported protocols
- Estimate rewards for positions
- Automatic notifications for new rewards

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

## Running the Bot

To start the bot, run:

```
ruby lib/wizard/of/rhiz/bot.rb
```

## Usage

In Discord, you can use the following commands:

- `!balance [protocol]` - Check your balance for a specific protocol
- `!rewards [protocol]` - Check your estimated rewards for a specific protocol
- `!help` - Show the help message with available commands

## Development

To run tests:

```
rspec
```

To run the linter:

```
standardrb
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a pull request

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.
