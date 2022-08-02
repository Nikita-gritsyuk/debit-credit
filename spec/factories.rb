FactoryBot.define do
  factory :transfer_transaction do
    amount { 1000 }
  end

  factory(:user) do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    # incoming_transfer_transactions { build_list(:transfer_transaction, 5) }
  end
end
