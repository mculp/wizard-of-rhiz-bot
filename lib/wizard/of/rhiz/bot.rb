require 'discordrb'
require 'httparty'
require 'dotenv/load'
require 'logger'
require_relative 'api'

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
          @api_base_url = ENV['API_BASE_URL'] || 'http://localhost:9292/api'
          @logger = Logger.new(STDOUT)

          @bot.message(start_with: '!balance') do |event|
            handle_balance_command(event)
          end

          @bot.message(start_with: '!rewards') do |event|
            handle_rewards_command(event)
          end

          @bot.message(content: '!help') do |event|
            event.respond(help_message)
          end

          setup_notification_system
        end

        def run
          @bot.run
        end

        private

        def handle_balance_command(event)
          protocol = event.message.content.split[1]&.downcase
          unless valid_protocol?(protocol)
            return event.respond("Invalid protocol. Available protocols: #{API_URLS.keys.join(', ')}")
          end

          user = find_or_create_user(event.user.id.to_s)
          positions = fetch_positions(protocol, user['discord_id'])

          if positions.empty?
            event.respond("No positions found for #{protocol.capitalize}")
          else
            response = format_positions(positions, protocol)
            event.respond(response)
          end
        rescue StandardError => e
          @logger.error("Error in handle_balance_command: #{e.message}")
          event.respond("An error occurred while processing your request. Please try again later.")
        end

        def handle_rewards_command(event)
          protocol = event.message.content.split[1]&.downcase
          unless valid_protocol?(protocol)
            return event.respond("Invalid protocol. Available protocols: #{API_URLS.keys.join(', ')}")
          end

          user = find_or_create_user(event.user.id.to_s)
          positions = fetch_positions(protocol, user['discord_id'])

          if positions.empty?
            event.respond("No positions found for #{protocol.capitalize}")
          else
            rewards = estimate_rewards(positions, protocol)
            response = format_rewards(rewards, protocol)
            event.respond(response)
          end
        rescue StandardError => e
          @logger.error("Error in handle_rewards_command: #{e.message}")
          event.respond("An error occurred while processing your request. Please try again later.")
        end

        def find_or_create_user(discord_id)
          response = HTTParty.post("#{@api_base_url}/users", body: { discord_id: discord_id })
          JSON.parse(response.body)
        rescue StandardError => e
          @logger.error("Error in find_or_create_user: #{e.message}")
          raise
        end

        def fetch_positions(protocol, discord_id)
          response = HTTParty.get("#{@api_base_url}/positions/user_tracked", query: { discord_id: discord_id, exchange: protocol })
          JSON.parse(response.body)
        rescue StandardError => e
          @logger.error("Error in fetch_positions: #{e.message}")
          raise
        end

        def estimate_rewards(positions, protocol)
          rewards = []
          positions.each do |position|
            pool_details = calculate_pool_details(protocol, position['pool_address'])
            response = HTTParty.get("#{@api_base_url}/positions/rewards", query: {
              pool_address: position['pool_address'],
              exchange: protocol,
              position_id: position['position_id']
            })
            reward = JSON.parse(response.body)
            reward['pool_price'] = pool_details['price']
            reward['pool_liquidity'] = pool_details['formatted_liquidity']
            rewards << reward
          end
          rewards
        rescue StandardError => e
          @logger.error("Error in estimate_rewards: #{e.message}")
          raise
        end

        def format_positions(positions, protocol)
          response = "Your positions for #{protocol.capitalize}:\n\n"
          positions.each do |position|
            pool_details = calculate_pool_details(protocol, position['pool_address'])
            position_details = calculate_position_details(protocol, position['position_id'])
            response += "Pool: #{position['pool_address']}\n"
            response += "Token0: #{position['token0_address']} - Amount: #{position_details['amount0']}\n"
            response += "Token1: #{position['token1_address']} - Amount: #{position_details['amount1']}\n"
            response += "Tick Range: #{position['lower_tick']} to #{position['upper_tick']}\n"
            response += "Current Tick: #{pool_details['tick']}\n"
            response += "Pool Price: #{pool_details['price']}\n"
            response += "Pool Liquidity: #{pool_details['formatted_liquidity']}\n"
            response += "Status: #{position['in_range'] ? 'In Range' : 'Out of Range'}\n\n"
          end
          response
        end

        def format_rewards(rewards, protocol)
          response = "Estimated rewards for #{protocol.capitalize}:\n\n"
          rewards.each_with_index do |reward, index|
            response += "Position #{index + 1}:\n"
            response += "Estimated Reward: #{reward['estimated_reward']} #{REWARD_TOKEN_NAMES[protocol.to_sym]}\n"
            response += "Token0 Reward: #{reward['token0_reward']}\n"
            response += "Token1 Reward: #{reward['token1_reward']}\n"
            response += "Pool Price: #{reward['pool_price']}\n"
            response += "Pool Liquidity: #{reward['pool_liquidity']}\n\n"
          end
          response
        end

        def help_message
          <<~HELP
            Available commands:
            !balance [protocol] - Check your balance for a specific protocol
            !rewards [protocol] - Check your estimated rewards for a specific protocol
            !help - Show this help message

            Available protocols: #{API_URLS.keys.join(', ')}
          HELP
        end

        def setup_notification_system
          Thread.new do
            loop do
              check_and_send_notifications
              sleep 120 # Check every 2 minutes
            end
          end
        end

        def check_and_send_notifications
          users = fetch_all_users
          users.each do |user|
            API_URLS.keys.each do |protocol|
              positions = fetch_positions(protocol, user['discord_id'])
              rewards = estimate_rewards(positions, protocol)
              send_notification(user, protocol, rewards) if should_notify?(rewards)
              check_and_update_position_status(user, protocol, positions)
            end
          end
        rescue StandardError => e
          @logger.error("Error in check_and_send_notifications: #{e.message}")
        end

        def fetch_all_users
          response = HTTParty.get("#{@api_base_url}/users/all")
          JSON.parse(response.body)
        rescue StandardError => e
          @logger.error("Error in fetch_all_users: #{e.message}")
          raise
        end

        def should_notify?(rewards)
          rewards.any? { |reward| reward['estimated_reward'].to_f > 10 }
        end

        def send_notification(user, protocol, rewards)
          channel = @bot.user(user['discord_id'].to_i).pm
          message = "New rewards available for #{protocol.capitalize}:\n\n"
          message += format_rewards(rewards, protocol)
          channel.send_message(message)
        rescue StandardError => e
          @logger.error("Error in send_notification: #{e.message}")
        end

        def valid_protocol?(protocol)
          API_URLS.key?(protocol.to_sym)
        end

        def check_and_update_position_status(user, protocol, positions)
          positions.each do |position|
            current_status = fetch_current_position_status(protocol, position['position_id'])
            if current_status != position['in_range']
              update_position_status(position['id'], current_status)
              send_range_notification(user, protocol, position, current_status)
            end
          end
        end

        def fetch_current_position_status(protocol, position_id)
          response = HTTParty.get("#{@api_base_url}/positions/status", query: {
            exchange: protocol,
            position_id: position_id
          })
          JSON.parse(response.body)['in_range']
        rescue StandardError => e
          @logger.error("Error in fetch_current_position_status: #{e.message}")
          raise
        end

        def update_position_status(position_id, new_status)
          HTTParty.put("#{@api_base_url}/positions/#{position_id}", body: { in_range: new_status })
        rescue StandardError => e
          @logger.error("Error in update_position_status: #{e.message}")
        end

        def send_range_notification(user, protocol, position, new_status)
          channel = @bot.user(user['discord_id'].to_i).pm
          status_text = new_status ? "in range" : "out of range"
          message = "Position status change for #{protocol.capitalize}:\n"
          message += "Pool: #{position['pool_address']}\n"
          message += "Position ID: #{position['position_id']}\n"
          message += "New status: #{status_text}\n"
          channel.send_message(message)
        rescue StandardError => e
          @logger.error("Error in send_range_notification: #{e.message}")
        end

        def calculate_pool_details(protocol, pool_address)
          response = HTTParty.get("#{@api_base_url}/pools/details", query: {
            exchange: protocol,
            pool_address: pool_address
          })
          JSON.parse(response.body)
        rescue StandardError => e
          @logger.error("Error in calculate_pool_details: #{e.message}")
          raise
        end

        def calculate_position_details(protocol, position_id)
          response = HTTParty.get("#{@api_base_url}/positions/from_chain", query: {
            exchange: protocol,
            position_id: position_id
          })
          JSON.parse(response.body)
        rescue StandardError => e
          @logger.error("Error in calculate_position_details: #{e.message}")
          raise
        end
      end
    end
  end
end
