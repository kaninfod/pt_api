module Api
  class AlbumsController < ApplicationController
    set_pagination_headers :photos, only: [:photos]
    before_action :set_album, only: [:show, :update, :destroy, :photos, :add_photo]
    include Response
    include ExceptionHandler


    # PUT /albums/:id/photo/:id
    def add_photo
      @album.add_photos([params[:photo]])
      json_response(@album.album_photos)
    end

    # GET /albums
    def index
      @albums = Album.all
      render json: @albums
    end

    # GET /albums/:id/photos
    def photos
      @photos = @album.album_photos.paginate(:page => params[:page], :per_page=>60)
      render 'api/photos/index'
    end

    # GET /albums/:id
    def show
      json_response(@album)
    end

    # POST /albums
    def create
      @album = Album.create!(album_params)
      json_response(@album, :created)
    end

    # PUT /albums/:id
    def update
      @album.update(album_params)
      json_response(@album, :accepted)
    end

    # DELETE /albums/:id
    def destroy
      @album.destroy
      json_response(@album, :ok)
    end

    private

      def album_params
        params.require(:album).permit(:start, :end, :name, :make, :model, :country, :city, :photo_ids, :album_type, {:tags=>[123]})
      end

      def set_album
        @album = Album.find(params[:id])
      end

  end
end
