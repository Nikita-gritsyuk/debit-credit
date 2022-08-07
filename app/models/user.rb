class User < ApplicationRecord
  include ModelRestrictions
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :validatable
  validates :email, uniqueness: true
  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  has_many :incoming_transfer_transactions, class_name: 'TransferTransaction', foreign_key: 'receiver_id'
  has_many :outgoing_transfer_transactions, class_name: 'TransferTransaction', foreign_key: 'sender_id'

  restrict_destroy

  def transfer_transactions
    incoming_transfer_transactions.or(outgoing_transfer_transactions)
  end

  # restrict manual balance updates
  def balance=(_value)
    return if new_record?

    raise ActiveRecord::ActiveRecordError, 'Manual balance update is not allowed'
  end

  # Single-query balance recounting. It works faster then geting two sum's by
  # grouping and MUCH faster then recalculating it on ruby side
  # I realy tried to implement something similar with AR calculation,
  # but it can not provide required API
  # https://api.rubyonrails.org/v7.0.3/classes/ActiveRecord/Calculations.html
  def recalculate_balance!
    binds = [ActiveRecord::Relation::QueryAttribute.new('id', id, ActiveRecord::Type::Integer.new)]
    ActiveRecord::Base.connection.exec_query(balance_recalculation_sql_query, 'sql', binds)
    reload
  end

  private

  def balance_recalculation_sql_query
    <<-SQL
      UPDATE users SET balance = COALESCE(result.sum, 0) FROM (
        SELECT SUM(
          COALESCE((receiver_id = $1)::int * 2 - 1, -1) * transfer_transactions.amount
        ) as sum
        FROM transfer_transactions
        WHERE sender_id = $1 OR receiver_id = $1
      ) result WHERE users.id = $1
    SQL
  end
end
