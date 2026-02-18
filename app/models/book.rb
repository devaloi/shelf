class Book < ApplicationRecord
  belongs_to :user
  has_many :book_tags, dependent: :destroy
  has_many :tags, through: :book_tags

  enum :status, { unread: 0, reading: 1, read: 2 }

  validates :title, presence: true
  validates :author, presence: true
  validates :rating, numericality: { only_integer: true, in: 1..5 }, allow_nil: true
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true

  scope :by_status, ->(status) { where(status: status) }
  scope :by_tag, ->(tag_name) { joins(:tags).where(tags: { name: tag_name }) }
  scope :recently_added, -> { order(created_at: :desc) }
  # SQLite LIKE search — simple and dependency-free. Adequate for personal
  # reading lists. For production scale, consider pg_search or Elasticsearch.
  scope :search, lambda { |query|
    where('title LIKE :q OR author LIKE :q OR notes LIKE :q', q: "%#{sanitize_sql_like(query)}%")
  }
end
