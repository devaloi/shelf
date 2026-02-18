require 'rails_helper'

RSpec.describe AuthService do
  let(:payload) { { user_id: 1 } }

  describe '.encode' do
    it 'returns a JWT token' do
      token = described_class.encode(payload)
      expect(token).to be_a(String)
      expect(token.split('.').length).to eq(3)
    end

    it 'includes the payload' do
      token = described_class.encode(payload)
      decoded = described_class.decode(token)
      expect(decoded[:user_id]).to eq(1)
    end

    it 'includes an expiration time' do
      token = described_class.encode(payload)
      decoded = described_class.decode(token)
      expect(decoded[:exp]).to be_present
    end
  end

  describe '.decode' do
    let(:token) { described_class.encode(payload) }

    it 'decodes a valid token' do
      decoded = described_class.decode(token)
      expect(decoded[:user_id]).to eq(1)
    end

    it 'returns a hash with indifferent access' do
      decoded = described_class.decode(token)
      expect(decoded[:user_id]).to eq(decoded['user_id'])
    end

    context 'when token is expired' do
      it 'raises AuthError' do
        expired_token = JWT.encode(
          { user_id: 1, exp: 1.hour.ago.to_i },
          Rails.application.secret_key_base,
          'HS256'
        )

        expect { described_class.decode(expired_token) }
          .to raise_error(AuthService::AuthError, 'Token has expired')
      end
    end

    context 'when token is invalid' do
      it 'raises AuthError for malformed token' do
        expect { described_class.decode('invalid.token.here') }
          .to raise_error(AuthService::AuthError, /Invalid token/)
      end

      it 'raises AuthError for token with wrong signature' do
        wrong_signature_token = JWT.encode(payload, 'wrong_secret', 'HS256')

        expect { described_class.decode(wrong_signature_token) }
          .to raise_error(AuthService::AuthError, /Invalid token/)
      end
    end
  end
end
