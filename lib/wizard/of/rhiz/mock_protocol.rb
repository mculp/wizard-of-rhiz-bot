require 'rack'
require 'json'

module Wizard
  module Of
    module Rhiz
      class MockProtocol
        def call(env)
          req = Rack::Request.new(env)
          
          if req.path == "/mixed-pairs"
            [200, {"Content-Type" => "application/json"}, [mock_mixed_pairs.to_json]]
          else
            [404, {"Content-Type" => "text/plain"}, ["Not Found"]]
          end
        end

        private

        def mock_mixed_pairs
          [
            {
              id: "0x1234...5678",
              token0: {
                id: "0xabcd...ef01",
                symbol: "TOKEN0",
                name: "Token 0",
                decimals: 18
              },
              token1: {
                id: "0x2345...6789",
                symbol: "TOKEN1",
                name: "Token 1",
                decimals: 18
              },
              reserve0: "1000000000000000000",
              reserve1: "2000000000000000000",
              totalSupply: "1414213562373095048",
              reserveUSD: "1000.00",
              volumeUSD: "10000.00",
              feesUSD: "30.00",
              txCount: 100,
              apr: "10.5"
            }
          ]
        end
      end
    end
  end
end

# To run the mock server:
# require 'rack'
# Rack::Handler::WEBrick.run Wizard::Of::Rhiz::MockProtocol.new, Port: 9292