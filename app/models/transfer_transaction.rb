class TransferTransaction < ApplicationRecord
  include ActiveModel::Validations
  validates_with TransferTransactionValidator, on: :create

  validates :amount, numericality: { greater_than_or_equal_to: 0 }, presence: true

  belongs_to :sender, class_name: 'User', optional: true
  belongs_to :receiver, class_name: 'User', optional: true

  scope :inner, -> { where.not(sender: nil).and(where.not(receiver: nil)) }
  scope :system_incoming, -> { where(sender: nil).and(where.not(receiver: nil)) }
  scope :system_outgoing, -> { where.not(sender: nil).and(where(receiver: nil)) }

  before_create :update_sender_balance
  before_create :update_receiver_balance

  private

  def update_receiver_balance
    return if receiver.nil? || !new_record?

    receiver.update_attribute(:balance, receiver.balance + amount)
  end

  def update_sender_balance
    return if sender.nil? || !new_record?

    sender.update_attribute(:balance, sender.balance - amount)
  end
end
