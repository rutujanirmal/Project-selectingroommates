Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get "users", to: "users#index"

  post "user/new", to: "users#new"

  get "user_details", to: "users#user_details"

  post "booking", to: "rooms#new"
end
