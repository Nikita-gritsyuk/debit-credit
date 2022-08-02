class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transfer_transaction_form, only: :create
  before_action :set_transfer_transactions

  decorates_assigned :transactions

  def index
    @create_transfer_transaction_form = CreateTransferTransactionForm.new
  end

  def create
    if @create_transfer_transaction_form.save
      redirect_to root_path, notice: 'Transaction was successfully created.'
    else
      set_transfer_transactions
      render :index, status: :unprocessable_entity
    end
  end

  private

  def permitted_params
    params.require(:create_transfer_transaction_form).permit(:receiver_email, :amount)
  end

  def set_transfer_transaction_form
    @create_transfer_transaction_form = CreateTransferTransactionForm.new(
      sender: current_user,
      receiver_email: permitted_params[:receiver_email],
      amount: permitted_params[:amount]
    )
  end

  def set_transfer_transactions
    @transactions = current_user.transfer_transactions
                                .includes(:sender, :receiver)
                                .order(created_at: :desc)
                                .paginate(page: params[:page])
                                .decorate(context: { current_user: })
  end
end
