module Wizard
  module Of
    module Rhiz
      module Config
        RPC_URLS = {
          nile: ENV['LINEA_RPC'] || "https://rpc.linea.build",
          pharaoh: ENV['AVALANCHE_RPC'] || "https://avalanche.drpc.org",
          nuri: ENV['SCROLL_RPC'] || "https://scroll.drpc.org",
          ra: ENV['FRAX_RPC'] || "https://rpc.frax.com",
          cleo: ENV['MANTLE_RPC'] || "https://mantle.drpc.org",
          ramses: ENV['ARBITRUM_RPC'] || "https://arbitrum.drpc.org",
        }

        NFPM_ADDRESSES = {
          nile: "0xAAA78E8C4241990B4ce159E105dA08129345946A",
          pharaoh: "0xAAA78E8C4241990B4ce159E105dA08129345946A",
          nuri: "0xAAA78E8C4241990B4ce159E105dA08129345946A",
          ra: "0xAAA78E8C4241990B4ce159E105dA08129345946A",
          cleo: "0xAAA78E8C4241990B4ce159E105dA08129345946A",
          ramses: "0xAA277CB7914b7e5514946Da92cb9De332Ce610EF",
        }

        CHAIN_IDS = {
          nile: 59144,
          pharaoh: 43114,
          nuri: 534352,
          ra: 252,
          cleo: 5000,
          ramses: 42161,
        }

        POOL_INIT_CODE_HASHES = {
          nile: "0x1565b129f2d1790f12d45301b9b084335626f0c92410bc43130763b69971135d",
          pharaoh: "0x1565b129f2d1790f12d45301b9b084335626f0c92410bc43130763b69971135d",
          nuri: "0x1565b129f2d1790f12d45301b9b084335626f0c92410bc43130763b69971135d",
          ra: "0x1565b129f2d1790f12d45301b9b084335626f0c92410bc43130763b69971135d",
          cleo: "0x1565b129f2d1790f12d45301b9b084335626f0c92410bc43130763b69971135d",
          ramses: "0x1565b129f2d1790f12d45301b9b084335626f0c92410bc43130763b69971135d",
        }

        FACTORIES = {
          nile: "0xAAA32926fcE6bE95ea2c51cB4Fcb60836D320C42",
          pharaoh: "0xAAA32926fcE6bE95ea2c51cB4Fcb60836D320C42",
          nuri: "0xAAA32926fcE6bE95ea2c51cB4Fcb60836D320C42",
          ra: "0xAAA32926fcE6bE95ea2c51cB4Fcb60836D320C42",
          cleo: "0xAAA32926fcE6bE95ea2c51cB4Fcb60836D320C42",
          ramses: "0xAA2cd7477c451E703f3B9Ba5663334914763edF8",
        }
      end
    end
  end
end 