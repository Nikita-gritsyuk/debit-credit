require 'rails_helper'

RSpec.describe CreateTransferTransactionForm, type: :form do
  let(:user) { create(:user) }

  describe 'validations' do
    describe 'common validations' do
      it { should validate_presence_of(:amount) }
      it { should validate_numericality_of(:amount).is_greater_than(0) }
    end

    it 'should be invalid if receiver_email is not a registered user' do
      transfer_transaction_form = CreateTransferTransactionForm.new(sender: nil, receiver_email: Faker::Internet.email)
      expect(transfer_transaction_form).to be_invalid
      expect(transfer_transaction_form.errors[:receiver_email]).to include('is invalid')
    end

    it 'should be invalid if sender and receiver are the same user' do
      transfer_transaction_form = CreateTransferTransactionForm.new(sender: user,
                                                                    receiver_email: user.email,
                                                                    amount: 100)

      expect(transfer_transaction_form).to be_invalid

      expect(transfer_transaction_form.errors[:base]).to include('Sender and receiver must be different users')
    end
  end
end
