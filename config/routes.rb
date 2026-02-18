Rails.application.routes.draw do
  # Health check
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Authentication
  post 'auth/register', to: 'auth#register'
  post 'auth/login', to: 'auth#login'

  # Books
  resources :books, only: %i[index show create update destroy] do
    collection do
      get :search
    end
  end
end
