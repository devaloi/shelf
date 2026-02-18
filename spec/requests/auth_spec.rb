require 'rails_helper'

RSpec.describe 'Auth', type: :request do
  describe 'POST /auth/register' do
    let(:valid_params) { { email: 'test@example.com', password: 'password123' } }

    context 'with valid parameters' do
      it 'creates a new user' do
        expect { post '/auth/register', params: valid_params }
          .to change(User, :count).by(1)
      end

      it 'returns a token' do
        post '/auth/register', params: valid_params
        expect(response).to have_http_status(:created)
        expect(json_response['token']).to be_present
      end

      it 'returns the user data' do
        post '/auth/register', params: valid_params
        expect(json_response['user']['email']).to eq('test@example.com')
        expect(json_response['user']).not_to have_key('password_digest')
      end
    end

    context 'with invalid parameters' do
      it 'returns errors for missing email' do
        post '/auth/register', params: { password: 'password123' }
        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['details']).to include("Email can't be blank")
      end

      it 'returns errors for invalid email format' do
        post '/auth/register', params: { email: 'invalid', password: 'password123' }
        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['details']).to include('Email is invalid')
      end

      it 'returns errors for short password' do
        post '/auth/register', params: { email: 'test@example.com', password: 'short' }
        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['details']).to include('Password is too short (minimum is 6 characters)')
      end

      it 'returns errors for duplicate email' do
        create(:user, email: 'test@example.com')
        post '/auth/register', params: valid_params
        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['details']).to include('Email has already been taken')
      end
    end
  end

  describe 'POST /auth/login' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'returns a token' do
        post '/auth/login', params: { email: 'test@example.com', password: 'password123' }
        expect(response).to have_http_status(:ok)
        expect(json_response['token']).to be_present
      end

      it 'returns the user data' do
        post '/auth/login', params: { email: 'test@example.com', password: 'password123' }
        expect(json_response['user']['email']).to eq('test@example.com')
        expect(json_response['user']['id']).to eq(user.id)
      end
    end

    context 'with invalid credentials' do
      it 'returns error for wrong password' do
        post '/auth/login', params: { email: 'test@example.com', password: 'wrongpassword' }
        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Invalid email or password')
      end

      it 'returns error for non-existent email' do
        post '/auth/login', params: { email: 'nonexistent@example.com', password: 'password123' }
        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Invalid email or password')
      end
    end
  end

  def json_response
    response.parsed_body
  end
end
