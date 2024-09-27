class CreateInitialSchema < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :discord_id, null: false, index: { unique: true }
      t.timestamps
    end

    create_table :positions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :protocol, null: false
      t.string :pool_address, null: false
      t.string :token0_address, null: false
      t.string :token1_address, null: false
      t.decimal :amount0, precision: 30, scale: 18, null: false
      t.decimal :amount1, precision: 30, scale: 18, null: false
      t.integer :tick_lower, null: false
      t.integer :tick_upper, null: false
      t.timestamps
    end

    create_table :tokens do |t|
      t.string :address, null: false, index: { unique: true }
      t.string :symbol, null: false
      t.string :name
      t.integer :decimals, null: false
      t.timestamps
    end
  end
end