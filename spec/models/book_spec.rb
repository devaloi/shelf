require 'rails_helper'

RSpec.describe Book do
  describe 'validations' do
    subject { build(:book) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:author) }
    it { is_expected.to validate_numericality_of(:rating).only_integer.is_in(1..5).allow_nil }

    it 'validates url format' do
      book = build(:book, url: 'invalid-url')
      expect(book).not_to be_valid
      expect(book.errors[:url]).to include('is invalid')
    end

    it 'accepts valid url' do
      book = build(:book, url: 'https://example.com')
      expect(book).to be_valid
    end

    it 'accepts nil url' do
      book = build(:book, url: nil)
      expect(book).to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:book_tags).dependent(:destroy) }
    it { is_expected.to have_many(:tags).through(:book_tags) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(unread: 0, reading: 1, read: 2) }
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let!(:unread_book) { create(:book, user: user, status: :unread, title: 'Unread Book') }
    let!(:reading_book) { create(:book, user: user, status: :reading, title: 'Reading Book') }
    let!(:read_book) { create(:book, :read, user: user, title: 'Read Book') }

    describe '.by_status' do
      it 'returns books with the specified status' do
        expect(described_class.by_status(:unread)).to contain_exactly(unread_book)
        expect(described_class.by_status(:reading)).to contain_exactly(reading_book)
        expect(described_class.by_status(:read)).to contain_exactly(read_book)
      end
    end

    describe '.by_tag' do
      let(:tag) { create(:tag, name: 'fiction', user: user) }

      before { unread_book.tags << tag }

      it 'returns books with the specified tag' do
        expect(described_class.by_tag('fiction')).to contain_exactly(unread_book)
      end
    end

    describe '.recently_added' do
      it 'returns books ordered by created_at desc' do
        expect(described_class.recently_added.first).to eq(read_book)
      end
    end

    describe '.search' do
      it 'searches by title' do
        expect(described_class.search('Unread')).to contain_exactly(unread_book)
      end

      it 'searches by author' do
        book = create(:book, user: user, author: 'Specific Author')
        expect(described_class.search('Specific')).to contain_exactly(book)
      end

      it 'searches by notes' do
        book = create(:book, user: user, notes: 'Some specific notes')
        expect(described_class.search('specific notes')).to contain_exactly(book)
      end
    end
  end
end
