require 'rails_helper'

RSpec.describe BookSearchService do
  let(:user) { create(:user) }
  let(:scope) { user.books }

  before do
    create(:book, user: user, title: 'Ruby Programming', author: 'Matz', notes: 'Great book')
    create(:book, user: user, title: 'Python Guide', author: 'Guido', notes: nil)
    create(:book, user: user, title: 'JavaScript Patterns', author: 'Stoyan', notes: 'Design patterns for JS')
  end

  describe '#call' do
    it 'searches by title' do
      results = described_class.new(scope).call('Ruby')
      expect(results.count).to eq(1)
      expect(results.first.title).to eq('Ruby Programming')
    end

    it 'searches by author' do
      results = described_class.new(scope).call('Guido')
      expect(results.count).to eq(1)
      expect(results.first.author).to eq('Guido')
    end

    it 'searches by notes' do
      results = described_class.new(scope).call('Design patterns')
      expect(results.count).to eq(1)
      expect(results.first.title).to eq('JavaScript Patterns')
    end

    it 'is case-insensitive' do
      results = described_class.new(scope).call('ruby')
      expect(results.count).to eq(1)
    end

    it 'returns empty for no matches' do
      results = described_class.new(scope).call('Nonexistent')
      expect(results.count).to eq(0)
    end

    it 'returns none for blank query' do
      results = described_class.new(scope).call('')
      expect(results.count).to eq(0)
    end

    it 'escapes SQL wildcards' do
      create(:book, user: user, title: '100% Complete', author: 'Test')
      results = described_class.new(scope).call('100%')
      expect(results.count).to eq(1)
    end
  end
end
