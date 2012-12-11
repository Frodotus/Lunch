Rails3BootstrapDeviseCancan::Application.routes.draw do
  resources :lunches

  authenticated :user do
    root :to => 'home#index'
  end
  root :to => "home#index"
  match "preferred" => "lunches#preferred"
  devise_for :users
  resources :users
end