FactoryBot.define do
  factory :transfer_transaction do
    amount { rand(100) }
  end

  factory(:user) do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
  end
end
