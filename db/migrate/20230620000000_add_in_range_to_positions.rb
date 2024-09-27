class AddInRangeToPositions < ActiveRecord::Migration[6.1]
  def change
    add_column :positions, :in_range, :boolean, default: true
  end
end