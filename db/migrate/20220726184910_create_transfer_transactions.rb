class CreateTransferTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transfer_transactions do |t|
      t.belongs_to :sender, foreign_key: { to_table: :users }, optional: true
      t.belongs_to :receiver, foreign_key: { to_table: :users }, optional: true
      t.decimal :amount, precision: 8, scale: 2, null: false
      t.timestamps
    end
  end
end
