require 'grape'
require 'eth'
require_relative 'config'
require_relative 'models/user'
require_relative 'models/position'
require_relative 'models/token'

module Wizard
  module Of
    module Rhiz
      class API < Grape::API
        format :json
        prefix :api

        helpers do
          def provider(exchange)
            Eth::Client.create Config::RPC_URLS[exchange.to_sym]
          end

          def nfpm_contract(exchange)
            address = Config::NFPM_ADDRESSES[exchange.to_sym]
            Eth::Contract.from_abi(name: "NonFungiblePositionManager", address: address, abi: NFPM_ABI)
          end

          def calculate_pool_values(pool)
            price = (pool[:sqrtPriceX96]**2 / 2**192).to_f
            liquidity = pool[:liquidity].to_f

            {
              price: price,
              liquidity: liquidity
            }
          end

          def calculate_position_values(position, pool)
            pool_values = calculate_pool_values(pool)
            lower_price = 1.0001**position[:lower_tick]
            upper_price = 1.0001**position[:upper_tick]

            amount0 = 0
            amount1 = 0

            if pool_values[:price] < lower_price
              amount0 = pool_values[:liquidity] * (1 / Math.sqrt(lower_price) - 1 / Math.sqrt(upper_price))
            elsif pool_values[:price] > upper_price
              amount1 = pool_values[:liquidity] * (Math.sqrt(upper_price) - Math.sqrt(lower_price))
            else
              amount0 = pool_values[:liquidity] * (1 / Math.sqrt(pool_values[:price]) - 1 / Math.sqrt(upper_price))
              amount1 = pool_values[:liquidity] * (Math.sqrt(pool_values[:price]) - Math.sqrt(lower_price))
            end

            {
              amount0: amount0,
              amount1: amount1
            }
          end

          def estimate_rewards(position, pool)
            position_values = calculate_position_values(position, pool)
            # This is a simplified reward calculation. You may need to adjust this based on your specific reward mechanism.
            estimated_reward = (position_values[:amount0] + position_values[:amount1]) * 0.01 # Assuming 1% reward rate
            {
              estimated_reward: estimated_reward,
              token0_reward: position_values[:amount0] * 0.01,
              token1_reward: position_values[:amount1] * 0.01
            }
          end
        end

        resource :users do
          desc 'Get all users'
          get :all do
            User.all
          end

          desc 'Create or find user'
          params do
            requires :discord_id, type: String
          end
          post do
            User.find_or_create_by(discord_id: params[:discord_id])
          end
        end

        resource :positions do
          desc 'Get position from chain'
          params do
            requires :position_id, type: Integer
            requires :exchange, type: String
          end
          get :from_chain do
            position = nfpm_contract(params[:exchange]).call.positions(params[:position_id])
            # Process and return position data
            {
              position_id: params[:position_id],
              lower_tick: position[0],
              upper_tick: position[1],
              liquidity: position[2].to_i
            }
          end

          desc 'Get pool slot0 and liquidity'
          params do
            requires :token0, type: String
            requires :token1, type: String
            requires :fee, type: Integer
            requires :exchange, type: String
            optional :tick_spacing, type: Integer
          end
          get :pool_info do
            # This is a placeholder. You'll need to implement the actual logic to fetch this data from the blockchain.
            {
              sqrtPriceX96: Eth::Unit.new(1829744519839346793014845, 0),
              tick: 0,
              liquidity: Eth::Unit.new(1000 * 10**18, 0)
            }
          end

          desc 'Get position rewards'
          params do
            requires :pool_address, type: String
            requires :exchange, type: String
            requires :position_id, type: Integer
          end
          get :rewards do
            position = get(:from_chain, params[:position_id], params[:exchange])
            pool = get(:pool_info, params[:pool_address], params[:exchange])
            estimate_rewards(position, pool)
          end

          desc 'Get positions from database'
          params do
            requires :position_id, type: Integer
            requires :exchange, type: String
          end
          get :from_database do
            Position.where(position_id: params[:position_id], exchange: params[:exchange], burned: false)
          end

          desc 'Get all non-burned positions from database'
          get :all do
            Position.where(burned: false)
          end

          desc 'Insert position into database'
          params do
            requires :position_id, type: Integer
            requires :exchange, type: String
            requires :discord_id, type: String
            requires :lower_tick, type: Integer
            requires :upper_tick, type: Integer
            requires :liquidity, type: Integer
          end
          post :insert do
            Position.create(
              position_id: params[:position_id],
              exchange: params[:exchange],
              discord_id: params[:discord_id],
              lower_tick: params[:lower_tick],
              upper_tick: params[:upper_tick],
              liquidity: params[:liquidity],
              in_range: true # Default to true, update later if needed
            )
          end

          desc 'Update position in-range status'
          params do
            requires :position_id, type: Integer
            requires :in_range, type: Boolean
            requires :exchange, type: String
          end
          put :update_range do
            position = Position.find_by(position_id: params[:position_id], exchange: params[:exchange])
            position.update(in_range: params[:in_range])
          end

          desc 'Mark position as burned'
          params do
            requires :position_id, type: Integer
            requires :exchange, type: String
          end
          put :burn do
            position = Position.find_by(position_id: params[:position_id], exchange: params[:exchange])
            position.update(burned: true)
          end

          desc 'Remove position from database'
          params do
            requires :position_id, type: Integer
            requires :discord_id, type: String
            requires :exchange, type: String
          end
          delete :remove do
            Position.where(position_id: params[:position_id], discord_id: params[:discord_id], exchange: params[:exchange]).destroy_all
          end

          desc 'Get user tracked positions'
          params do
            requires :discord_id, type: String
          end
          get :user_tracked do
            Position.where(discord_id: params[:discord_id], burned: false)
          end

          desc 'Remove all positions for a user'
          params do
            requires :discord_id, type: String
          end
          delete :remove_all do
            Position.where(discord_id: params[:discord_id]).destroy_all
          end

          desc 'Get position status'
          params do
            requires :exchange, type: String
            requires :position_id, type: Integer
          end
          get :status do
            position = Position.find_by(position_id: params[:position_id], exchange: params[:exchange])
            { in_range: position.in_range }
          end

          desc 'Update position status'
          params do
            requires :id, type: Integer
            requires :in_range, type: Boolean
          end
          put ':id' do
            position = Position.find(params[:id])
            position.update(in_range: params[:in_range])
            { success: true }
          end
        end

        resource :pools do
          desc 'Get pool details'
          params do
            requires :exchange, type: String
            requires :pool_address, type: String
          end
          get :details do
            # This is a placeholder. You'll need to implement the actual logic to fetch this data from the blockchain.
            pool = {
              sqrtPriceX96: Eth::Unit.new(1829744519839346793014845, 0),
              liquidity: Eth::Unit.new(1000 * 10**18, 0),
              tick: 0,
              observationIndex: 50,
              observationCardinality: 100,
              observationCardinalityNext: 100,
              feeProtocol: 5,
              unlocked: true
            }
            pool_values = calculate_pool_values(pool)
            pool.merge(
              price: pool_values[:price],
              formatted_liquidity: pool_values[:liquidity]
            )
          end
        end

        # Add other resources and endpoints as needed
      end
    end
  end
end