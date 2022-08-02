require 'rails_helper'

describe 'Creating new transfer', type: :system do
  let(:sender) { create :user }
  let(:receiver) { create :user }

  before do
    TransferTransaction.create(receiver: sender, amount: 100)
    login_as sender
    visit root_path
  end

  scenario 'creating new transaction' do
    fill_in 'create_transfer_transaction_form[receiver_email]', with: receiver.email
    fill_in 'create_transfer_transaction_form[amount]', with: '25.12'
    click_button 'Transfer'

    with_retries do
      expect(first('table tbody tr')).to have_text '- 25.12'
      expect(first('table tbody tr')).to have_text receiver.email
      expect(first('table tbody tr')).to have_text sender.email
      expect(page).to have_text 'Balance: 74.88 $'
      expect(page).to have_text 'Transaction was successfully created.'
    end
  end

  scenario 'creating new transaction with invalid email' do
    fill_in 'create_transfer_transaction_form[receiver_email]', with: Faker::Internet.email
    fill_in 'create_transfer_transaction_form[amount]', with: '25.12'
    click_button 'Transfer'

    with_retries do
      expect(first('table tbody tr')).to have_no_text '- 25.12'
      expect(first('table tbody tr')).to have_no_text receiver.email
      expect(page).to have_text '- Receiver email is invalid'
    end
  end
end
