require 'rails_helper'

RSpec.describe 'Transactions', type: :request do
  describe 'GET /' do
    let(:user) { create(:user) }

    it 'should redirect to authentication page if user is not signed in' do
      get root_path
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(new_user_session_path)
    end

    describe 'when user is signed in' do
      before do
        sign_in user
        # let user to have 100 incoming transactions in his account
        FactoryBot.create_list :transfer_transaction, 100, receiver: user, amount: 100
        # and 1 outgoing transaction, the last one
        FactoryBot.create :transfer_transaction, sender: user, amount: 100
      end

      it 'should display transactions list on the page' do
        get root_path
        expect(response.body).to include('<p class="text-success"> + 100.0</p>')
        expect(response.body).to include('<p class="text-danger"> - 100.0</p>')
      end

      it 'should paginate transactions list if :page param is present' do
        get root_path(page: 2)
        expect(response.body).to include('<p class="text-success"> + 100.0</p>')
        # outgoing transaction should not be displayed on page 2, this transaction is the last one
        expect(response.body).to_not include('<p class="text-danger"> - 100.0</p>')
      end

      it 'should show actual balance on the page' do
        get root_path
        expect(response.body).to include("Balance: #{user.balance} $")
      end

      it 'should display transactions list on the page' do
        sign_in user
        get root_path
      end
    end
  end

  describe 'post /transactions' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:valid_params) do
      {
        create_transfer_transaction_form: {
          sender: user,
          receiver_email: other_user.email,
          amount: 100
        }
      }
    end
    let(:params_with_invalid_email) do
      {
        create_transfer_transaction_form: {
          sender: user,
          receiver_email: Faker::Internet.email,
          amount: 100
        }
      }
    end
    let(:params_with_invalid_amount) do
      {
        create_transfer_transaction_form: {
          sender: user,
          receiver_email: other_user.email,
          amount: -100
        }
      }
    end

    context 'when user is signed in' do
      context 'when params are valid' do
        before do
          sign_in user
          other_user
          create(:transfer_transaction, receiver: user, amount: 100)
        end

        it 'should create new transaction' do
          expect { post transactions_path, params: valid_params }.to change { TransferTransaction.count }.by(1)
        end

        it 'should update sender balance' do
          expect { post transactions_path, params: valid_params }.to change { user.reload.balance }.by(-100)
        end

        it 'should update receiver balance' do
          expect { post transactions_path, params: valid_params }.to change { other_user.reload.balance }.by(100)
        end
      end

      context 'when user have no enough balance' do
        before do
          sign_in user
          create(:transfer_transaction, receiver: user, amount: 10)
        end

        it 'should not create new transaction' do
          expect { post transactions_path, params: valid_params }.to_not change(TransferTransaction, :count)
        end

        it 'should not update sender balance' do
          expect { post transactions_path, params: valid_params }.to_not change(user.reload, :balance)
        end

        it 'should not update receiver balance' do
          expect { post transactions_path, params: valid_params }.to_not change(other_user.reload, :balance)
        end

        it 'should display error message' do
          post transactions_path, params: valid_params
          expect(response.body).to include('Sender have no enough balance')
        end
      end

      context 'when receiver is not a registered user' do
        before do
          sign_in user
          other_user
          create(:transfer_transaction, receiver: user, amount: 100)
        end

        it 'should not create new transaction' do
          expect { post transactions_path, params: params_with_invalid_email }.to_not change(TransferTransaction, :count)
        end

        it 'should not update sender balance' do
          expect { post transactions_path, params: params_with_invalid_email }.to_not change(user.reload, :balance)
        end

        it 'should not update receiver balance' do
          expect { post transactions_path, params: params_with_invalid_email }.to_not change(other_user.reload, :balance)
        end

        it 'should display error message' do
          post transactions_path, params: params_with_invalid_email
          expect(response.body).to include('Receiver email is invalid')
        end
      end

      context 'when amount has invalid value' do
        before do
          sign_in user
          create(:transfer_transaction, receiver: user, amount: 100)
        end

        it 'should not create new transaction' do
          expect { post transactions_path, params: params_with_invalid_amount }.to_not change(TransferTransaction, :count)
        end

        it 'should not update sender balance' do
          expect { post transactions_path, params: params_with_invalid_amount }.to_not change(user.reload, :balance)
        end

        it 'should not update receiver balance' do
          expect { post transactions_path, params: params_with_invalid_amount }.to_not change(other_user.reload, :balance)
        end

        it 'should display error message' do
          post transactions_path, params: params_with_invalid_amount
          expect(response.body).to include('Amount must be greater than 0')
        end
      end
    end

    context 'when user is not signed in' do
      it 'should redirect to authentication page' do
        post transactions_path, params: valid_params
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
