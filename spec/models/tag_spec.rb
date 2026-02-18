require 'rails_helper'

RSpec.describe Tag do
  describe 'validations' do
    subject { build(:tag) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:user_id).case_insensitive }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:book_tags).dependent(:destroy) }
    it { is_expected.to have_many(:books).through(:book_tags) }
  end

  describe 'normalizations' do
    it 'normalizes name to downcase and strips whitespace' do
      user = create(:user)
      tag = create(:tag, name: '  FICTION  ', user: user)
      expect(tag.name).to eq('fiction')
    end
  end

  describe '#books_count' do
    let(:user) { create(:user) }
    let(:tag) { create(:tag, user: user) }

    it 'returns the number of books with this tag' do
      books = create_list(:book, 3, user: user)
      books.each { |book| book.tags << tag }

      expect(tag.books_count).to eq(3)
    end

    it 'returns 0 when no books have this tag' do
      expect(tag.books_count).to eq(0)
    end
  end
end
