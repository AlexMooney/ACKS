# frozen_string_literal: true

Rails.application.routes.draw do
  resources :characters do
    collection do
      get :generate
    end
  end

  root "home#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
