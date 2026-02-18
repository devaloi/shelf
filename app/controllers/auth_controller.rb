class AuthController < ApplicationController
  skip_before_action :authenticate_request, only: %i[register login]

  def register
    user = User.new(user_params)

    if user.save
      token = AuthService.encode(user_id: user.id)
      render json: { token: token, user: user_response(user) }, status: :created
    else
      render json: { error: 'Registration failed', details: user.errors.full_messages }, status: :unprocessable_content
    end
  end

  def login
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      token = AuthService.encode(user_id: user.id)
      render json: { token: token, user: user_response(user) }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  private

  def user_params
    params.permit(:email, :password)
  end

  def user_response(user)
    {
      id: user.id,
      email: user.email,
      created_at: user.created_at
    }
  end
end
