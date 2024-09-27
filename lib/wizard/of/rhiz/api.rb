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

          # Add other helper methods as needed
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
            # You'll need to implement the logic similar to getPositionFromChain in api.ts
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
            # Implement logic similar to getPoolSlot0AndLiquidity in api.ts
          end

          desc 'Get position rewards'
          params do
            requires :pool_address, type: String
            requires :exchange, type: String
            requires :position_id, type: Integer
          end
          get :rewards do
            # Implement logic to calculate and return position rewards
            # This is a placeholder implementation
            {
              estimated_reward: rand(1..100),
              token0_reward: rand(1..50),
              token1_reward: rand(1..50)
            }
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
            # Add other necessary parameters
          end
          post :insert do
            Position.create(
              position_id: params[:position_id],
              exchange: params[:exchange],
              discord_id: params[:discord_id]
              # Add other parameters
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
        end

        # Add other resources and endpoints as needed
      end
    end
  end
end