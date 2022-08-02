class CreateTransferTransactionForm
  include ActiveModel::Model

  validates :amount, numericality: { greater_than: 0 }, presence: true
  validate :receiver_exists

  attr_accessor :amount, :sender, :receiver_email

  def initialize(params = {})
    @sender = params[:sender]
    @amount = params[:amount]
    @receiver_email = params[:receiver_email]
    @receiver = User.find_by(email: params[:receiver_email]&.downcase)

    @transfer_transaction = TransferTransaction.new(
      sender: @sender,
      receiver: @receiver,
      amount: @amount
    )
  end

  def valid?(context = nil)
    return true if super(context) && @transfer_transaction.valid?

    @transfer_transaction.errors.full_messages.each do |message|
      errors.add(:base, message)
    end
    false
  end

  def save
    @transfer_transaction.save if valid?
  end

  private

  def receiver_exists
    errors.add(:receiver_email, 'is invalid') unless @receiver.present?
  end
end
