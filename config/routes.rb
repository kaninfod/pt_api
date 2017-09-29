Rails.application.routes.draw do
  namespace :api, constraints: {format: :json} do

    post    '/users/login'                      => 'users#authenticate'
    get     '/users/from_token'                 => 'users#validate_token'

    resources :albums
    put     '/albums/:id/bucket'                => "albums#add_bucket"
    get     '/albums/:id/photos'                => 'albums#photos'

    get     'pages' => 'pages#index'
    get     '/photos/taglist'                   => 'photos#taglist'
    get     '/photos/bucket'                    => 'photos#bucket'
    post    '/photos/bucket/clear'              => 'photos#bucket_clear'
    post    '/photos/bucket/like'               => 'photos#bucket_like'
    post    '/photos/bucket/unlike'             => 'photos#bucket_unlike'
    post    '/photos/bucket/rotate/'            => 'photos#bucket_rotate'
    post    '/photos/bucket/add_to_album/'      => 'photos#bucket_add_to_album'
    post    '/photos/bucket/tag/add'            => 'photos#bucket_tag'
    delete  '/photos/bucket/tag/delete'         => 'photos#bucket_untag'
    post    '/photos/bucket/comment/add'        => 'photos#bucket_comment'
    delete  '/photos/bucket/comment/delete'     => 'photos#bucket_uncomment'
    resources :photos
    post    '/photos/:id/add_to_album'          => 'photos#add_to_album'
    post    '/photos/:id/rotate'                => 'photos#rotate'
    post    '/photos/:id/comment/add'           => 'photos#comment'
    delete  '/photos/:id/comment/delete'        => 'photos#uncomment'
    post    '/photos/:id/tag/add'               => 'photos#tag'
    delete  '/photos/:id/tag/delete'            => 'photos#untag'
    post    '/photos/:id/like'                  => 'photos#like_toggle'
    post    '/photos/:id/unlike'                => 'photos#like_toggle'
    post    '/photos/:id/bucket/toggle'         => 'photos#bucket_toggle'

    get     '/catalogs/oauth_callback'
    get     '/catalogs/:id/import'              => 'catalogs#import'
    get     '/catalogs/:id/photos'              => 'catalogs#photos'
    resources :catalogs

    get     '/locations/countries'
    get     '/locations/cities'
    resources :locations

    resources :photofiles
    get     'photofiles/:id/photoserve' => 'photofiles#photoserve'
    patch   'photofiles/:id/rotate' => 'photofiles#rotate'
    get     'photofiles/:id/phash' => 'photofiles#phash'

    post    'jobs/list' => 'jobs#list'
    resources :jobs
  end

  # Rails.application.routes.draw do
  #   resources :users, controller: 'users', only: [:create, :edit, :update]
  # end

  mount Resque::Server.new, at: "/resque"
  root to: 'photos#index'

end
