require 'rails_helper'

RSpec.describe 'BookTags', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:token) { AuthService.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }
  let(:book) { create(:book, user: user) }

  describe 'POST /books/:book_id/tags' do
    context 'with existing tag' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let!(:tag) { create(:tag, user: user, name: 'ruby') }

      it 'adds the tag to the book' do
        expect { post "/books/#{book.id}/tags", params: { tags: ['ruby'] }, headers: headers }
          .to change(book.tags, :count).by(1)
      end

      it 'returns the updated book with tags' do
        post "/books/#{book.id}/tags", params: { tags: ['ruby'] }, headers: headers
        expect(response).to have_http_status(:created)
        expect(json_response['data']['tags'].pluck('name')).to include('ruby')
      end

      it 'does not duplicate tags' do
        book.tags << tag
        expect { post "/books/#{book.id}/tags", params: { tags: ['ruby'] }, headers: headers }
          .not_to change(book.tags, :count)
      end
    end

    context 'with new tag' do
      it 'creates the tag and adds it to the book' do
        expect { post "/books/#{book.id}/tags", params: { tags: ['new-tag'] }, headers: headers }
          .to change(user.tags, :count).by(1)
        expect(book.reload.tags.pluck(:name)).to include('new-tag')
      end
    end

    it 'normalizes tag names' do
      post "/books/#{book.id}/tags", params: { tags: ['  Ruby Programming  '] }, headers: headers
      expect(user.tags.last.name).to eq('ruby programming')
    end

    it 'cannot add tags to another user book' do
      other_book = create(:book, user: other_user)
      post "/books/#{other_book.id}/tags", params: { tags: ['hacked'] }, headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /books/:book_id/tags/:id' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:tag) { create(:tag, user: user) }

    before { book.tags << tag }

    it 'removes the tag from the book' do
      expect { delete "/books/#{book.id}/tags/#{tag.id}", headers: headers }
        .to change(book.tags, :count).by(-1)
    end

    it 'does not delete the tag itself' do
      expect { delete "/books/#{book.id}/tags/#{tag.id}", headers: headers }
        .not_to change(Tag, :count)
    end

    it 'returns the updated book data' do
      delete "/books/#{book.id}/tags/#{tag.id}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['tags']).to be_empty
    end

    it 'returns 404 for tag not on book' do
      other_tag = create(:tag, user: user)
      delete "/books/#{book.id}/tags/#{other_tag.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end

    it 'cannot remove tags from another user book' do
      other_book = create(:book, user: other_user)
      other_tag = create(:tag, user: other_user)
      other_book.tags << other_tag

      delete "/books/#{other_book.id}/tags/#{other_tag.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  def json_response
    response.parsed_body
  end
end
