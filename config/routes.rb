Rails.application.routes.draw do
  # Health check
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Authentication
  post 'auth/register', to: 'auth#register'
  post 'auth/login', to: 'auth#login'
end
