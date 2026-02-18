class ApplicationController < ActionController::API
  before_action :authenticate_request

  attr_reader :current_user

  private

  def authenticate_request
    token = extract_token
    return render_unauthorized('Missing authorization token') unless token

    payload = AuthService.decode(token)
    @current_user = User.find_by(id: payload[:user_id])
    render_unauthorized('Invalid token') unless @current_user
  rescue AuthService::AuthError => e
    render_unauthorized(e.message)
  end

  def extract_token
    header = request.headers['Authorization']
    return nil unless header

    header.split.last
  end

  def render_unauthorized(message)
    render json: { error: message }, status: :unauthorized
  end
end
