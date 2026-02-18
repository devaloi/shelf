class AuthController < ApplicationController
  skip_before_action :authenticate_request, only: %i[register login]

  def register
    user = User.new(user_params)

    if user.save
      token = AuthService.encode(user_id: user.id)
      render json: { data: { token: token, user: UserSerializer.new(user).as_json } }, status: :created
    else
      render json: { error: 'Registration failed', details: user.errors.full_messages }, status: :unprocessable_content
    end
  end

  # Authenticate: look up user by email (case-insensitive), verify password
  # via bcrypt's authenticate method, and return a signed JWT on success.
  def login
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      token = AuthService.encode(user_id: user.id)
      render json: { data: { token: token, user: UserSerializer.new(user).as_json } }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  private

  def user_params
    params.permit(:email, :password)
  end
end
