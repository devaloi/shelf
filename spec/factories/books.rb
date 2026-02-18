FactoryBot.define do
  factory :book do
    user
    sequence(:title) { |n| "Book Title #{n}" }
    author { 'Test Author' }
    isbn { nil }
    status { :unread }
    rating { nil }
    notes { nil }
    url { nil }

    trait :reading do
      status { :reading }
    end

    trait :read do
      status { :read }
      rating { 4 }
    end

    trait :with_rating do
      rating { rand(1..5) }
    end

    trait :with_url do
      url { 'https://example.com/book' }
    end
  end
end
