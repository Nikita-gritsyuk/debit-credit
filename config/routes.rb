Rails.application.routes.draw do
  root 'transactions#index'
  post 'transactions' => 'transactions#create', as: :transactions
  devise_for :users
end
