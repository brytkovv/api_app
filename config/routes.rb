Rails.application.routes.draw do

  resources :users
  resources :categories do
    resources :posts do
      resources :comments do
      end
    end
  end

end
