class ApplicationController < ActionController::API
  before_action :authenticate_request

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable
  rescue_from AuthService::AuthError, with: :render_auth_error

  attr_reader :current_user

  private

  # Token-based auth: extract JWT from Authorization header, decode it,
  # and set current_user. All controllers inherit this before_action.
  # Returns 401 with specific error messages for missing, expired, or invalid tokens.
  def authenticate_request
    token = extract_token
    return render_unauthorized('Missing authorization token') unless token

    payload = AuthService.decode(token)
    @current_user = User.find_by(id: payload[:user_id])
    render_unauthorized('Invalid token') unless @current_user
  end

  def extract_token
    header = request.headers['Authorization']
    return nil unless header

    parts = header.split
    return nil unless parts.length == 2 && parts.first.downcase == 'bearer'

    parts.last
  end

  def render_not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def render_unprocessable(exception)
    render json: { error: 'Validation failed', details: exception.record.errors.full_messages },
           status: :unprocessable_content
  end

  def render_auth_error(exception)
    render json: { error: exception.message }, status: :unauthorized
  end

  def render_unauthorized(message)
    render json: { error: message }, status: :unauthorized
  end

  def render_bad_request(message)
    render json: { error: message }, status: :bad_request
  end
end
