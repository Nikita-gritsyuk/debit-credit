FactoryBot.define do
  factory :transfer_transaction do
    amount { rand(100) }
    sender nil
    receiver nil
  end

  factory(:user) do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
  end
end
