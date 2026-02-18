class BookTag < ApplicationRecord
  belongs_to :book
  belongs_to :tag

  validates :book_id, uniqueness: { scope: :tag_id }
end
