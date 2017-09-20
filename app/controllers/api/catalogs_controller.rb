
  class API::CatalogsController < ApplicationController
    skip_before_action :authenticate_request, :only => [:oauth_callback]
    set_pagination_headers :photos, only: [:photos]
    before_action :set_catalog, only: [:show, :update, :destroy, :photos, :oauth_verify, :import]
    include Response
    include ExceptionHandler


    def index
      @catalogs = Catalog.order(:id).page params[:page]
      render json: @catalogs, root: 'catalogs'
    end

    def show
      @catalog = Catalog.find(params[:id])
      render json: @catalog, root: 'catalogs'
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
      render json: @catalog, root: 'catalogs'
    end

    def update
      if @catalog.update(catalog_params)
        render json: @catalog, root: 'catalogs'
      end
      return
    end

    def destroy
      @catalog.destroy
      render json: @catalog
    end

    def photos
      @photos = @catalog.photos.paginate(:page => params[:page], :per_page=>60)
      _pagi = {
        total: @photos.total_entries,
        total_pages: @photos.total_pages,
        first_page: @photos.current_page == 1,
        last_page: @photos.next_page.blank?,
        previous_page: @photos.previous_page,
        next_page: @photos.next_page,
        out_of_bounds: @photos.out_of_bounds?,
        offset: @photos.offset
      }
      render json: @photos, each_serializer: PhotoSerializer, meta: _pagi
    end

    def import
      response = @catalog.import
      render :json => { response: response }
    end

    def oauth_callback
      @catalog = Catalog.find get_catalog_id
      code = params[:oauth_verifier] || params[:code]
      @catalog.oauth_callback(code)
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
