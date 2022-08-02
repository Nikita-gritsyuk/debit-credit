require 'rails_helper'

RSpec.describe User, type: :model do
  it 'should not set balance directly' do
    user = create(:user)
    user.balance = 100
    expect(user.balance).to eq(0)
  end

  it 'should not update balance directly' do
    user = create(:user)
    user.update(balance: 100)
    expect(user.reload.balance).to eq(0)
  end
end
