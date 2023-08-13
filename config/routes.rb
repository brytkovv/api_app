Rails.application.routes.draw do

  resources :users
  resources :categories do
    resources :posts do
      resources :comments do
      end

      get "/uploads/:model/:id/:attachment/:filename", to: "active_storage/representations#show", constraints: { filename: /[^\/]+/ }
    end
  end

end
