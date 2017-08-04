
  class API::CatalogsController < ApplicationController
    skip_before_action :authenticate_request, :only => [:oauth_callback]
    set_pagination_headers :photos, only: [:photos]
    before_action :set_catalog, only: [:show, :update, :destroy, :photos, :oauth_verify, :import]
    include Response
    include ExceptionHandler


    def index
      @catalogs = Catalog.order(:id).page params[:page]
      render json: @catalogs
    end

    def show
      @catalog = Catalog.find(params[:id])
      render json: @catalog
    end

    def create
      new_catalog = catalog_params
      new_catalog[:user] = @current_user

      if ['DropboxCatalog', 'FlickrCatalog'].include? new_catalog['type']
        new_catalog[:redirect_uri] = request.base_url
        @catalog= Catalog.create!(new_catalog)
        @catalog = @catalog.oauth_init
      elsif new_catalog['type'] == 'MasterCatalog'
        new_catalog[:default] = true
        @catalog= Catalog.create!(new_catalog)
      end
      render json: @catalog
    end

    def update
      if @catalog.update(catalog_params)
        render json: @catalog
      end
      return
    end

    def destroy
      @catalog.destroy
      render json: @catalog
    end

    def photos
      @photos = @catalog.photos.paginate(:page => params[:page], :per_page=>60)
      render json: @photos, each_serializer: PhotoSimpleSerializer
    end

    def import
      response = @catalog.import
      render :json => { response: response }
    end

    def oauth_callback
      @catalog = Catalog.find get_catalog_id
      @catalog.oauth_callback(params[:code])
      render json: @catalog, status: 200
    end

    private
      def get_catalog_id
        if params.include? :state
          return params[:state]
        elsif params.include? :catalog_id
          return params[:catalog_id]
        end
      end

      def set_catalog
        @catalog = Catalog.find(params[:id])
      end

      def catalog_params
        params.require(:catalog).permit(
          :name,
          :path,
          :default,
          :watch_path,
          :type,
          :sync_from_catalog,
          :sync_from_albums,
          :import_mode
        )
      end
  end


# def oauth_verify
#   verifier = params[:oauth_verifier]
#
#   @catalog.update(verifier: verifier)
#   if @catalog.callback
#     render json: @catalog
#   else
#     render json: @catalog, status: :not_acceptable
#   end
# end

# def authorize()
#   if request.put?
#     catalog = DropboxCatalog.find(params[:id])
#     catalog.update(verifier: params[:verifier])
#     if catalog.callback
#       redirect_to action: 'edit', id: catalog
#     end
#   else
#     if params[:type] == 'DropboxCatalog'
#       @catalog = DropboxCatalog.new(name: params[:name])
#       @catalog.redirect_uri = request.base_url
#       @catalog.save
#       @auth_url = @catalog.auth
#     elsif params[:type] == 'FlickrCatalog'
#       catalog = FlickrCatalog.new(name: params[:name])
#       catalog.redirect_uri = request.base_url
#       catalog.save
#       auth_url = catalog.auth
#       redirect_to auth_url
#     end
#   end
# end


# def authorize_callback
#   if params.has_key? :type
#     if params[:type] == "FlickrCatalog"
#       flickr_catalog = FlickrCatalog.find(params[:id])
#       flickr_catalog.verifier = params[:oauth_verifier]
#       flickr_catalog.save
#       if flickr_catalog.callback
#         redirect_to action: 'edit', id: flickr_catalog
#       end
#     end
#   else
#   end
# end


          # def update
          #   if @catalog.update(catalog_params)
          #     render json: @catalog
          #   end
          #   return

            # case @catalog.type
            #   when "MasterCatalog"
            #     if @catalog.update(catalog_params)
            #       render json: @catalog
            #     end
            #     return
            #   when "LocalCatalog"
            #     catalog_attribs = update_local
            #     if @catalog.update(catalog_attribs)
            #       render json: @catalog
            #     end
            #   when "DropboxCatalog"
            #     catalog_attribs = update_dropbox
            #     if @catalog.update(catalog_attribs)
            #       render json: @catalog
            #     end
            #   when "FlickrCatalog"
            #     catalog_attribs = update_dropbox
            #     if @catalog.update(catalog_attribs)
            #       render json: @catalog
            #     end
            # end
          # end


          # def dashboard
          #   @catalog = Catalog.find(params[:id])
          #   @jobs = Job.order(created_at: :desc, id: :desc ).paginate(:page => params[:page], :per_page => 10)
          # end



          # def get_catalog
          #   render :json => Catalog.find(params[:id]).to_json
          # end



    # def update_master
    #   catalog_attribs = params.permit(:name, :type, :path, :import_mode)
    #   catalog_attribs['watch_path'] = generate_watch_path
    #   #catalog_attribs['import_mode'] = params['import_mode']
    #
    #   return catalog_attribs
    # end
    #
    # def update_local
    #   catalog_attribs = params.permit(:name, :type, :path)
    #   if params[:sync_from] == "catalog"
    #     catalog_attribs['sync_from_catalog'] = params[:sync_from_catalog_id]
    #     catalog_attribs['sync_from_albums'] = nil
    #   elsif params[:sync_from] == "album"
    #     albums = []
    #     params.each do |k, v|
    #       albums.push(v) if (k.include?('sync_from_album_id_') & not(v.blank?))
    #     end
    #     catalog_attribs['sync_from_albums'] = albums
    #     catalog_attribs['sync_from_catalog'] = nil
    #   end
    #   return catalog_attribs
    # end
    #
    # def update_dropbox
    #   catalog_attribs = params.permit(:name, :type, :path, :access_token, :verifier)
    #   catalog_attribs['sync_from_catalog'] = params[:sync_from_catalog_id]
    #   catalog_attribs['sync_from_albums'] = nil
    #   return catalog_attribs
    # end
    #
    # def generate_watch_path
    #   watch_path =[]
    #   params.each do |k, v|
    #     watch_path.push(v) if (k.include?('wp_') & not(v.blank?))
    #   end
    #   return watch_path
    # end
