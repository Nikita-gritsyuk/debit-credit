class AddBalanceToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :balance, :decimal, precision: 8,
                                           scale: 2,
                                           default: 0,
                                           null: false
  end
end
