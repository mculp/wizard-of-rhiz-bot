require 'discordrb'
require 'httparty'
require 'active_record'
require 'dotenv/load'

module Wizard
  module Of
    module Rhiz
      class Bot
        API_URLS = {
          nile: "https://nile-api-production.up.railway.app/mixed-pairs",
          nuri: "https://nuri-api-production.up.railway.app/mixed-pairs",
          ra: "https://ra-api-production.up.railway.app/mixed-pairs",
          cleo: "https://cleopatra-api-production.up.railway.app/mixed-pairs",
          pharaoh: "https://pharaoh-api-production.up.railway.app/mixed-pairs",
          ramses: "https://api-v2-production-a6e6.up.railway.app/mixed-pairs",
        }.freeze

        REWARD_TOKEN_NAMES = {
          nile: "NILE",
          nuri: "NURI",
          ramses: "RAM",
          cleo: "CLEO",
          pharaoh: "PHAR",
        }.freeze

        def initialize
          @bot = Discordrb::Bot.new token: ENV['DISCORD_BOT_TOKEN']

          @bot.message(start_with: '!balance') do |event|
            handle_balance_command(event)
          end

          @bot.message(content: '!help') do |event|
            event.respond(help_message)
          end
        end

        def run
          @bot.run
        end

        private

        def handle_balance_command(event)
          protocol = event.message.content.split[1]&.downcase
          unless API_URLS.key?(protocol.to_sym)
            return event.respond("Invalid protocol. Available protocols: #{API_URLS.keys.join(', ')}")
          end

          user = find_or_create_user(event.user.id)
          positions = fetch_positions(protocol, user)

          if positions.empty?
            event.respond("No positions found for #{protocol.capitalize}")
          else
            response = format_positions(positions, protocol)
            event.respond(response)
          end
        end

        def find_or_create_user(discord_id)
          User.find_or_create_by(discord_id: discord_id)
        end

        def fetch_positions(protocol, user)
          # In a real implementation, this would fetch positions from the database
          # For now, we'll return a mock position
          [{
            pool_address: "0x1234...5678",
            token0_address: "0xabcd...ef01",
            token1_address: "0x2345...6789",
            amount0: 100.0,
            amount1: 200.0,
            tick_lower: -100,
            tick_upper: 100
          }]
        end

        def format_positions(positions, protocol)
          response = "Your positions for #{protocol.capitalize}:\n\n"
          positions.each do |position|
            response += "Pool: #{position[:pool_address]}\n"
            response += "Token0: #{position[:token0_address]} - Amount: #{position[:amount0]}\n"
            response += "Token1: #{position[:token1_address]} - Amount: #{position[:amount1]}\n"
            response += "Tick Range: #{position[:tick_lower]} to #{position[:tick_upper]}\n\n"
          end
          response
        end

        def help_message
          <<~HELP
            Available commands:
            !balance [protocol] - Check your balance for a specific protocol
            !help - Show this help message

            Available protocols: #{API_URLS.keys.join(', ')}
          HELP
        end
      end
    end
  end
end
