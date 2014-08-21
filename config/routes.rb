SpottyMouth::Application.routes.draw do
  resources :users, :except => [:edit, :update] do
    match '/changepassword' => 'passwords#edit', :via => :get
    match '/passwordreset' => 'passwords#update', :via => :put
    resources :insults, :only => [:index, :create]
    member do
      get :following, :followers, :voters_for, :voters_against
    end
  end
  resources :insults, :only => [] do
    resources :comments, :only => [:index, :new, :create]
  end
  resources :daily_questions, :except => [:edit] do
    resources :daily_answers, :only => :create
  end
  
  resource :user, :only => [:edit, :update]
  
  resources :passwords, :only => [:create]
  resources :sessions, :only => [:new, :create, :destroy]
  resources :insults, :only => [:destroy]
  resources :relationships, :only => [:create, :destroy]
  resources :comments, :only => [:destroy]
  resources :daily_answers, :only => :destroy
  resources :answer_marks, :only => [:create, :destroy]

  match ':controller/:id/voters_for' => 'insults#voters_for', :as => :voters_for_insult
  match ':controller/:id/voters_against' => 'insults#voters_against', :as => :voters_against_insult
  match '/forgot_password', :to => 'passwords#new'
  match '/signup', :to => 'users#new'
  match '/signin', :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'
  match '/contact', :to => 'pages#contact'
  match '/terms_and_conditions', :to => 'pages#terms_and_conditions'
  match '/findvictim', :to => 'pages#find_victim'
  match '/votedownuser/:id' => 'votes#vote_down_user', :as => :vote_down_user
  match '/voteupuser/:id' => 'votes#vote_up_user', :as => :vote_up_user
  match '/votedowninsult/:id' => 'votes#vote_down_insult', :as => :vote_down_insult
  match '/voteupinsult/:id' => 'votes#vote_up_insult', :as => :vote_up_insult
  match '/walloffame', :to => 'walls#wall_of_fame'
  match '/wallofshame', :to => 'walls#wall_of_shame'
  match '/beef_with/:id' => 'users#beef_with', :as => :beef_with
  match '/archive' => 'daily_questions#archive', :as => :daily_questions_archive
  root :to => 'pages#home'
end
