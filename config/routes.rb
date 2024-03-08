Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    get '/tasks/overdue', to: "tasks#overdue"
    get '/tasks/completed', to: "tasks#completed"
    get '/tasks/statistics', to: "tasks#statistics"
    resources :tasks
    resources :users, only: :create
    post '/tasks/:id/assign', to: "tasks#assign"
    put '/tasks/:id/progress', to: "tasks#update_progress"

    get '/tasks/status/:status', to: "tasks#tasks_by_status"

    get '/users/:id/tasks', to: "users#tasks"
  end
end
