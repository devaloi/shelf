class User < ApplicationRecord
  has_secure_password

  has_many :books, dependent: :destroy
  has_many :tags, dependent: :destroy

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  normalizes :email, with: ->(email) { email.strip.downcase }
end
