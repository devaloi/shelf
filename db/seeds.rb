# rubocop:disable Rails/Output
# Create demo user
puts 'Creating demo user...'
demo_user = User.find_or_create_by!(email: 'demo@example.com') do |user|
  user.password = 'password123'
end

# Create tags
puts 'Creating tags...'
tags = %w[fiction non-fiction sci-fi fantasy biography self-help technical programming].map do |name|
  Tag.find_or_create_by!(name: name, user: demo_user)
end

# Sample books data
books_data = [
  {
    title: 'The Pragmatic Programmer',
    author: 'David Thomas, Andrew Hunt',
    isbn: '978-0135957059',
    status: :read,
    rating: 5,
    notes: 'Essential reading for any software developer. Great practical advice.',
    tags: %w[programming technical]
  },
  {
    title: 'Clean Code',
    author: 'Robert C. Martin',
    isbn: '978-0132350884',
    status: :read,
    rating: 4,
    notes: 'Good principles for writing maintainable code.',
    tags: %w[programming technical]
  },
  {
    title: 'Dune',
    author: 'Frank Herbert',
    isbn: '978-0441172719',
    status: :read,
    rating: 5,
    notes: 'A masterpiece of science fiction.',
    tags: %w[fiction sci-fi]
  },
  {
    title: 'Foundation',
    author: 'Isaac Asimov',
    isbn: '978-0553293357',
    status: :reading,
    rating: nil,
    notes: 'Classic sci-fi series.',
    tags: %w[fiction sci-fi]
  },
  {
    title: 'The Name of the Wind',
    author: 'Patrick Rothfuss',
    isbn: '978-0756404741',
    status: :unread,
    rating: nil,
    url: 'https://www.patrickrothfuss.com/content/books.asp',
    tags: %w[fiction fantasy]
  },
  {
    title: 'Sapiens: A Brief History of Humankind',
    author: 'Yuval Noah Harari',
    isbn: '978-0062316097',
    status: :read,
    rating: 4,
    notes: 'Fascinating overview of human history.',
    tags: %w[non-fiction]
  },
  {
    title: 'Atomic Habits',
    author: 'James Clear',
    isbn: '978-0735211292',
    status: :read,
    rating: 5,
    notes: 'Practical guide to building good habits.',
    tags: %w[non-fiction self-help]
  },
  {
    title: 'Steve Jobs',
    author: 'Walter Isaacson',
    isbn: '978-1451648539',
    status: :reading,
    rating: nil,
    tags: %w[non-fiction biography]
  },
  {
    title: 'Designing Data-Intensive Applications',
    author: 'Martin Kleppmann',
    isbn: '978-1449373320',
    status: :unread,
    rating: nil,
    notes: 'Comprehensive guide to data systems.',
    tags: %w[technical programming]
  },
  {
    title: 'The Hobbit',
    author: 'J.R.R. Tolkien',
    isbn: '978-0547928227',
    status: :read,
    rating: 5,
    tags: %w[fiction fantasy]
  },
  {
    title: '1984',
    author: 'George Orwell',
    isbn: '978-0451524935',
    status: :read,
    rating: 4,
    notes: 'Chilling and thought-provoking.',
    tags: %w[fiction]
  },
  {
    title: 'Refactoring',
    author: 'Martin Fowler',
    isbn: '978-0134757599',
    status: :unread,
    rating: nil,
    tags: %w[technical programming]
  }
]

# Create books
puts 'Creating books...'
books_data.each do |book_data|
  book_tags = book_data.delete(:tags) || []

  book = Book.find_or_create_by!(
    user: demo_user,
    title: book_data[:title]
  ) do |b|
    b.assign_attributes(book_data)
  end

  # Add tags to book
  book_tags.each do |tag_name|
    tag = tags.find { |t| t.name == tag_name }
    BookTag.find_or_create_by!(book: book, tag: tag) if tag
  end
end

puts 'Seeding complete!'
puts "Created #{User.count} user(s), #{Book.count} book(s), and #{Tag.count} tag(s)."
# rubocop:enable Rails/Output
