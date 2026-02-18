# Manual JWT authentication service — intentionally not using Devise
# to demonstrate understanding of token-based auth mechanics.
# Uses HS256 symmetric signing with Rails secret_key_base as the shared secret.
# Tokens expire after 24 hours to balance security with usability.
class AuthService
  ALGORITHM = 'HS256'.freeze
  TOKEN_EXPIRY = TOKEN_EXPIRY_HOURS.hours

  class << self
    def encode(payload)
      payload = payload.dup
      payload[:exp] = TOKEN_EXPIRY.from_now.to_i
      JWT.encode(payload, secret_key, ALGORITHM)
    end

    def decode(token)
      decoded = JWT.decode(token, secret_key, true, { algorithm: ALGORITHM })
      decoded.first.with_indifferent_access
    rescue JWT::ExpiredSignature
      raise AuthError, 'Token has expired'
    rescue JWT::DecodeError => e
      raise AuthError, "Invalid token: #{e.message}"
    end

    private

    def secret_key
      Rails.application.secret_key_base
    end
  end

  class AuthError < StandardError; end
end
