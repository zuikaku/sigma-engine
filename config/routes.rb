Sigma::Application.routes.draw do
  root :to => 'posts#index'

  scope 'threads' do
    match 'create'    => 'posts#create_thread'
    match ':id'       => 'posts#show',          constraints: {id: /\d+/}
    match ':id/reply' => 'posts#create_reply',  constraints: {id: /\d+/}
  end
  match 'page/:page'  => 'posts#page',          constraints: {id: /\d+/}

  match 'errors'      => 'application#errors'

  match '*path' => 'application#not_found'
end
