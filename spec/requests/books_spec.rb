require 'rails_helper'

RSpec.describe 'Books', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:token) { AuthService.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe 'GET /books' do
    before do
      create_list(:book, 3, user: user)
      create_list(:book, 2, user: other_user)
    end

    it 'returns only the current user books' do
      get '/books', headers: headers
      expect(response).to have_http_status(:ok)
      expect(json_response['data'].length).to eq(3)
    end

    it 'includes pagination metadata' do
      get '/books', headers: headers
      expect(json_response['meta']['total']).to eq(3)
      expect(json_response['meta']['page']).to eq(1)
    end

    context 'with pagination' do
      before { create_list(:book, 25, user: user) }

      it 'paginates results' do
        get '/books', params: { page: 1, per_page: 10 }, headers: headers
        expect(json_response['data'].length).to eq(10)
        expect(json_response['meta']['total_pages']).to eq(3)
      end

      it 'respects max per_page limit' do
        get '/books', params: { per_page: 200 }, headers: headers
        expect(json_response['data'].length).to eq(28) # 3 + 25
      end
    end

    context 'with filtering' do
      before do
        create(:book, user: user, status: :reading)
        create(:book, user: user, status: :read)
      end

      it 'filters by status' do
        get '/books', params: { status: 'reading' }, headers: headers
        expect(json_response['data'].length).to eq(1)
        expect(json_response['data'].first['status']).to eq('reading')
      end
    end

    context 'with search' do
      before do
        create(:book, user: user, title: 'Ruby Programming', author: 'Matz')
        create(:book, user: user, title: 'Python Guide', author: 'Guido')
      end

      it 'searches by title' do
        get '/books/search', params: { q: 'Ruby' }, headers: headers
        expect(json_response['data'].length).to eq(1)
        expect(json_response['data'].first['title']).to eq('Ruby Programming')
      end

      it 'searches by author' do
        get '/books/search', params: { q: 'Matz' }, headers: headers
        expect(json_response['data'].length).to eq(1)
      end
    end

    context 'with sorting' do
      before do
        create(:book, user: user, title: 'Z Book', rating: 5)
        create(:book, user: user, title: 'A Book', rating: 1)
      end

      it 'sorts by title ascending' do
        get '/books', params: { sort: 'title', order: 'asc' }, headers: headers
        titles = json_response['data'].pluck('title')
        expect(titles.first).to start_with('A')
      end

      it 'sorts by rating descending' do
        get '/books', params: { sort: 'rating', order: 'desc' }, headers: headers
        ratings = json_response['data'].pluck('rating')
        expect(ratings.first).to eq(5)
      end
    end

    it 'requires authentication' do
      get '/books'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /books/:id' do
    let(:book) { create(:book, user: user) }

    it 'returns the book' do
      get "/books/#{book.id}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['id']).to eq(book.id)
    end

    it 'includes tags' do
      tag = create(:tag, user: user)
      book.tags << tag
      get "/books/#{book.id}", headers: headers
      expect(json_response['data']['tags'].first['name']).to eq(tag.name)
    end

    it 'returns 404 for another user book' do
      other_book = create(:book, user: other_user)
      get "/books/#{other_book.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /books' do
    let(:valid_params) do
      {
        title: 'The Pragmatic Programmer',
        author: 'David Thomas',
        status: 'unread'
      }
    end

    it 'creates a book' do
      expect { post '/books', params: valid_params, headers: headers }
        .to change(user.books, :count).by(1)
    end

    it 'returns the created book' do
      post '/books', params: valid_params, headers: headers
      expect(response).to have_http_status(:created)
      expect(json_response['data']['title']).to eq('The Pragmatic Programmer')
    end

    context 'with invalid params' do
      it 'returns errors for missing title' do
        post '/books', params: { author: 'Someone' }, headers: headers
        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['details']).to include("Title can't be blank")
      end

      it 'returns errors for invalid rating' do
        post '/books', params: valid_params.merge(rating: 10), headers: headers
        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['details']).to include('Rating must be in 1..5')
      end

      it 'returns errors for invalid URL' do
        post '/books', params: valid_params.merge(url: 'not-a-url'), headers: headers
        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['details']).to include('Url is invalid')
      end
    end
  end

  describe 'PATCH /books/:id' do
    let(:book) { create(:book, user: user, title: 'Old Title') }

    it 'updates the book' do
      patch "/books/#{book.id}", params: { title: 'New Title' }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['title']).to eq('New Title')
    end

    it 'cannot update another user book' do
      other_book = create(:book, user: other_user)
      patch "/books/#{other_book.id}", params: { title: 'Hacked' }, headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /books/:id' do
    let!(:book) { create(:book, user: user) }

    it 'deletes the book' do
      expect { delete "/books/#{book.id}", headers: headers }
        .to change(user.books, :count).by(-1)
    end

    it 'returns no content' do
      delete "/books/#{book.id}", headers: headers
      expect(response).to have_http_status(:no_content)
    end

    it 'cannot delete another user book' do
      other_book = create(:book, user: other_user)
      delete "/books/#{other_book.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /books/search' do
    before do
      create(:book, user: user, title: 'Ruby Programming', author: 'Matz')
    end

    it 'returns matching books' do
      get '/books/search', params: { q: 'Ruby' }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(json_response['data'].length).to eq(1)
    end

    it 'returns 400 for empty query' do
      get '/books/search', params: { q: '' }, headers: headers
      expect(response).to have_http_status(:bad_request)
      expect(json_response['error']).to eq('Search query required')
    end

    it 'returns 400 for missing query parameter' do
      get '/books/search', headers: headers
      expect(response).to have_http_status(:bad_request)
    end

    it 'includes pagination metadata' do
      get '/books/search', params: { q: 'Ruby' }, headers: headers
      expect(json_response['meta']).to include('page', 'total')
    end
  end

  describe 'authentication edge cases' do
    it 'returns 401 for expired token' do
      expired_token = JWT.encode(
        { user_id: user.id, exp: 1.hour.ago.to_i },
        Rails.application.secret_key_base,
        'HS256'
      )
      get '/books', headers: { 'Authorization' => "Bearer #{expired_token}" }
      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body['error']).to eq('Token has expired')
    end

    it 'returns 401 for invalid token' do
      get '/books', headers: { 'Authorization' => 'Bearer invalid.token.here' }
      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body['error']).to include('Invalid token')
    end

    it 'returns 401 for missing token' do
      get '/books'
      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body['error']).to eq('Missing authorization token')
    end

    it 'returns 401 for token with non-existent user' do
      token = AuthService.encode(user_id: 99_999)
      get '/books', headers: { 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body['error']).to eq('Invalid token')
    end
  end

  def json_response
    response.parsed_body
  end
end
