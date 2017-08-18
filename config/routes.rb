Rails.application.routes.draw do
  namespace :api, constraints: {format: :json} do

    post    '/users/login'                       => 'users#authenticate'
    get     '/users/from_token'                  => 'users#validate_token'

    resources :albums
    put     '/albums/:id/photo/:photo'  => "albums#add_photo"
    put     '/albums/:id/bucket'        => "albums#add_bucket"
    get     '/albums/:id/photos'        => 'albums#photos'

    get     'pages' => 'pages#index'
    get     '/photos/taglist'                   => 'photos#taglist'
    get     '/photos/bucket'                    => 'photos#bucket'
    post    '/photos/bucket/like'               => 'photos#bucket_like'
    post    '/photos/bucket/rotate/'            => 'photos#bucket_rotate'

    get     '/photos/stats'                     => 'photos#stats'
    resources :photos
    get     '/photos/:id/rotate/(:degrees)'     => 'photos#rotate'
    post    '/photos/:id/comment/add'           => 'photos#comment'
    delete  '/photos/:id/comment/delete'        => 'photos#uncomment'
    post    '/photos/:id/tag/add'               => 'photos#tag'
    delete  '/photos/:id/tag/delete'            => 'photos#untag'
    post    '/photos/:id/like/toggle'           => 'photos#like_toggle'
    post    '/photos/:id/bucket/toggle'         => 'photos#bucket_toggle'


    get     '/catalogs/oauth_callback'
    get     '/catalogs/:id/import' => 'catalogs#import'
    get     '/catalogs/:id/photos' => 'catalogs#photos'
    resources :catalogs

    get     '/locations/countries'
    get     '/locations/cities'
    resources :locations

    post    'bucket/:id/toggle'     => 'bucket#toggle'
    post    'bucket/:id/add'        => 'bucket#add'
    post    'bucket/add_to_album'   => 'bucket#add_to_album'
    delete  'bucket/:id/remove'     => 'bucket#remove'
    post    'bucket/like'           => 'bucket#like'
    get     'bucket/widget'         => 'bucket#widget'
    post    '/bucket/rotate'        => 'bucket#rotate'
    post    'bucket/add_comment'    => 'bucket#add_comment'
    post    'bucket/add_tag'    => 'bucket#add_tag'

    post    'bucket/unlike'         => 'bucket#unlike'
    get     'bucket/list' => 'bucket#list'
    get     'bucket' => 'bucket#index'
    get     'bucket/clear' => 'bucket#clear'
    get     'bucket/count' => 'bucket#count'
    get     'bucket/save' => 'bucket#save_to_album'
    get     'bucket/delete_photos' => 'bucket#delete_photos'
    get     'bucket/edit' => 'bucket#edit'
    patch   'bucket/update' => 'bucket#update'

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
