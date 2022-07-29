class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :validatable
  validates :email, uniqueness: true
  validates :balance, numericality: { greater_than_or_equal_to: 0 }
end
