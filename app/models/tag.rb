class Tag < ApplicationRecord
  belongs_to :user
  has_many :book_tags, dependent: :destroy
  has_many :books, through: :book_tags

  validates :name, presence: true,
                   uniqueness: { scope: :user_id, case_sensitive: false }

  normalizes :name, with: ->(name) { name.strip.downcase }

  # Use .size to leverage preloaded associations (avoids N+1 COUNT queries)
  def books_count
    books.size
  end
end
