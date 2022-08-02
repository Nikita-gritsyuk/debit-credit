class TransferTransaction < ApplicationRecord
  include ActiveModel::Validations
  validates_with TransferTransactionValidator, on: :create

  validates :amount, numericality: { greater_than: 0 }, presence: true

  belongs_to :sender, class_name: 'User', optional: true
  belongs_to :receiver, class_name: 'User', optional: true

  scope :inner, -> { where.not(sender: nil).and(where.not(receiver: nil)) }
  scope :system_incoming, -> { where(sender: nil).and(where.not(receiver: nil)) }
  scope :system_outgoing, -> { where.not(sender: nil).and(where(receiver: nil)) }
  scope :related_to_user_id, ->(user_id) { where(sender_id: user_id).or(where(receiver_id: user_id)) }

  after_create :recalculate_subject_balances!

  private

  def recalculate_subject_balances!
    sender.lock!.recalculate_balance! if sender_id
    receiver.lock!.recalculate_balance! if receiver_id
  end
end
