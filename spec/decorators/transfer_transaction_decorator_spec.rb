require 'rails_helper'

RSpec.describe TransferTransactionDecorator do
  let(:sender) { create(:user) }
  let(:receiver) { create(:user) }
  let(:inner_transaction) { create(:transfer_transaction, sender:, receiver:, amount: 1917) }
  let(:system_incoming_transaction) { create(:transfer_transaction, receiver:, amount: 1917) }
  let(:system_outgoing_transaction) { create(:transfer_transaction, sender:, amount: 1917) }

  before do
    # add initial 100$ to subjects
    create(:transfer_transaction, receiver:, amount: 2000)
    create(:transfer_transaction, receiver: sender, amount: 2000)
  end

  describe '#sender_signature' do
    it 'should return sender email if sender is not nil' do
      expect(inner_transaction.decorate.sender_signature).to eq(sender.email)
    end

    it 'should return "DebitCredit (incoming transaction)" if sender is nil' do
      expect(system_incoming_transaction.decorate.sender_signature).to eq('DebitCredit (incoming transaction)')
    end
  end

  describe '#receiver_signature' do
    it 'should return receiver email if receiver is not nil' do
      expect(inner_transaction.decorate.receiver_signature).to eq(receiver.email)
    end

    it 'should return "DebitCredit (outgoing transaction)" if receiver is nil' do
      expect(system_outgoing_transaction.decorate.receiver_signature).to eq('DebitCredit (outgoing transaction)')
    end
  end

  describe '#formatted_amount' do
    it 'should return formated amount' do
      expect(inner_transaction.decorate.formated_amount).to eq('1917.00')
    end
  end

  context 'context is not present in decorator' do
    let(:decorated_transaction) { inner_transaction.decorate }

    describe('#incoming?') do
      it 'should return false' do
        expect(decorated_transaction.incoming?).to eq(false)
      end
    end

    describe('#outgoing?') do
      it 'should return false' do
        expect(decorated_transaction.outgoing?).to eq(false)
      end
    end
    describe('#styled_amoount') do
      it 'should return formatted amount' do
        expect(decorated_transaction.styled_amount).to eq('<p class="text-info">1917.00 $</p>')
      end
    end
  end

  context 'sender is present in decorator context as current_user' do
    let(:decorated_transaction) { inner_transaction.decorate(context: { current_user: sender }) }

    describe('#incoming?') do
      it 'should return true' do
        expect(decorated_transaction.incoming?).to eq(false)
      end
    end

    describe('#outgoing?') do
      it 'should return false' do
        expect(decorated_transaction.outgoing?).to eq(true)
      end
    end
    describe('#styled_amoount') do
      it 'should return formatted amount' do
        expect(decorated_transaction.styled_amount).to eq('<p class="text-danger">- 1917.00 $</p>')
      end
    end

    context 'receiver is present in decorator context as current_user' do
      let(:decorated_transaction) { inner_transaction.decorate(context: { current_user: receiver }) }

      describe('#incoming?') do
        it 'should return false' do
          expect(decorated_transaction.incoming?).to eq(true)
        end
      end

      describe('#outgoing?') do
        it 'should return true' do
          expect(decorated_transaction.outgoing?).to eq(false)
        end
      end
      describe('#styled_amoount') do
        it 'should return formatted amount' do
          expect(decorated_transaction.styled_amount).to eq('<p class="text-success">+ 1917.00 $</p>')
        end
      end
    end
  end
end
