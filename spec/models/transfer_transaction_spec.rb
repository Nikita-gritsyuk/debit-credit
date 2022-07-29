require 'rails_helper'

RSpec.describe TransferTransaction, type: :model do
  describe 'common validations' do
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
  end

  describe 'subjects validations' do
    it 'should validate presence of a sender or receiver' do
      transfer_transaction = TransferTransaction.new
      transfer_transaction.valid?
      expect(transfer_transaction.errors[:base]).to include('Transfer transaction must have a sender or receiver')
    end
  end

  describe 'sender balance validations' do
    it 'should be invalid if sender have no enough balance' do
      user = create(:user, balance: 0)
      transfer_transaction = build(:transfer_transaction, sender: user)
      transfer_transaction.valid?
      expect(transfer_transaction.errors[:base]).to include('Sender have no enough balance')
    end

    it 'should be valid if sender have enough balance' do
      user = create(:user, balance: 100)
      transfer_transaction = build(:transfer_transaction, sender: user)
      transfer_transaction.valid?
      expect(transfer_transaction.errors[:base]).to be_empty
    end
  end

  describe 'should update subjects balances' do
    it 'should update sender balance' do
      sender = create(:user, balance: 100)
      create(:transfer_transaction, sender:, amount: 73)
      expect(sender.reload.balance).to eq(27)
    end

    it 'should update receiver balance' do
      receiver = create(:user, balance: 100)
      create(:transfer_transaction, receiver:, amount: 73)
      expect(receiver.reload.balance).to eq(173)
    end

    it 'should update both balances for inner transactions' do
      sender = create(:user, balance: 100)
      receiver = create(:user, balance: 100)
      create(:transfer_transaction, sender:, receiver:, amount: 73)
      expect(sender.reload.balance).to eq(27)
      expect(receiver.reload.balance).to eq(173)
    end
  end
end
