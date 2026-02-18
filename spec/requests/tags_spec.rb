require 'rails_helper'

RSpec.describe 'Tags', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:token) { AuthService.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe 'GET /tags' do
    before do
      create_list(:tag, 3, user: user)
      create_list(:tag, 2, user: other_user)
    end

    it 'returns only the current user tags' do
      get '/tags', headers: headers
      expect(response).to have_http_status(:ok)
      expect(json_response['data'].length).to eq(3)
    end

    it 'includes books_count for each tag' do
      tag = user.tags.first
      create(:book, user: user).tags << tag
      create(:book, user: user).tags << tag

      get '/tags', headers: headers
      tag_response = json_response['data'].find { |t| t['id'] == tag.id }
      expect(tag_response['books_count']).to eq(2)
    end

    it 'requires authentication' do
      get '/tags'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /tags/:id/books' do
    let(:tag) { create(:tag, user: user) }

    before do
      create_list(:book, 3, user: user).each { |b| b.tags << tag }
      create(:book, user: user)
    end

    it 'returns books with the tag' do
      get "/tags/#{tag.id}/books", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json_response['data'].length).to eq(3)
    end

    it 'returns 404 for another user tag' do
      other_tag = create(:tag, user: other_user)
      get "/tags/#{other_tag.id}/books", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  def json_response
    response.parsed_body
  end
end
