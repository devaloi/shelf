require 'rails_helper'

RSpec.describe BookTag do
  describe 'validations' do
    subject { build(:book_tag) }

    it { is_expected.to validate_uniqueness_of(:book_id).scoped_to(:tag_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:book) }
    it { is_expected.to belong_to(:tag) }
  end
end
