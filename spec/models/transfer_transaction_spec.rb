require 'rails_helper'

RSpec.describe TransferTransaction, type: :model do
  describe 'common validations' do
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }
  end

  describe 'subjects validations' do
    let (:user) { create(:user) }
    it 'should validate presence of a sender or receiver' do
      transfer_transaction = TransferTransaction.new
      transfer_transaction.valid?
      expect(transfer_transaction.errors[:base]).to include('Transfer transaction must have a sender or receiver')
    end

    it 'should be invalid if sender and receiver are the same user' do
      transfer_transaction = TransferTransaction.new(sender: user, receiver: user)
      transfer_transaction.valid?
      expect(transfer_transaction.errors[:base]).to include('Sender and receiver must be different users')
    end
  end

  describe 'sender balance validations' do
    let(:user) { create(:user) }

    it 'should be invalid if sender have no enough balance' do
      transfer_transaction = build(:transfer_transaction, sender: user)
      transfer_transaction.valid?
      expect(transfer_transaction.errors[:base]).to include('Sender have no enough balance')
    end

    it 'should be valid if sender have enough balance' do
      create(:transfer_transaction, receiver: user, amount: 1000)
      transfer_transaction = build(:transfer_transaction, sender: user)
      transfer_transaction.valid?
      expect(transfer_transaction.errors[:base]).to be_empty
    end
  end

  describe 'should update subjects balances' do
    let(:sender) { create(:user) }
    let(:receiver) { create(:user) }

    before do
      # add initial 100$ to subjects
      create(:transfer_transaction, receiver:, amount: 100)
      create(:transfer_transaction, receiver: sender, amount: 100)
    end

    it 'should update sender balance for system outgoing transactions' do
      create(:transfer_transaction, sender:, amount: 73)
      expect(sender.reload.balance).to eq(27)
    end

    it 'should update receiver balance for system incoming transactions' do
      create(:transfer_transaction, receiver:, amount: 73)
      expect(receiver.reload.balance).to eq(173)
    end

    it 'should update both subjects balances for inner transactions' do
      create(:transfer_transaction, sender:, receiver:, amount: 73)
      expect(sender.reload.balance).to eq(27)
      expect(receiver.reload.balance).to eq(173)
    end
  end
end
