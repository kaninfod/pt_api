
  class API::PhotosController < ApplicationController
    skip_before_action :authenticate_request, only: :stats
    include Response
    include ExceptionHandler
    set_pagination_headers :photos, only: [:index]
    before_action :set_photo, only: [
      :destroy,
      :rotate,
      :show,
      :add_to_album,
      :comment, :uncomment,
      :like_toggle,
      :bucket_toggle,
      :tag, :untag
   ]

    def stats
      render html: 'yo'
    end

    #GET /api/photos/
    def index
      @album_hash = {}
      @order = "desc"
      get_album_hash
      @album = Album.new(@album_hash)
      #Get photos
      @photos = @album
              .album_photos
              .where('photos.status != ? or photos.status is ?', 1, nil)
              .includes(:facets)
              .includes(:location)
              .includes(location: :city)
              .includes(location: :country)
              .includes(facets: :user)
              .includes(facets: :tag)
              .includes(facets: :comment)
              .includes(facets: :album)
              .order(date_taken: @order)
              .paginate(:page => params[:page], :per_page=>params[:photosPerPage])

      # _pagi = {
      #   total: @photos.total_entries,
      #   total_pages: @photos.total_pages,
      #   first_page: @photos.current_page == 1,
      #   last_page: @photos.next_page.blank?,
      #   previous_page: @photos.previous_page,
      #   next_page: @photos.next_page,
      #   out_of_bounds: @photos.out_of_bounds?,
      #   offset: @photos.offset
      # }
      render json: @photos, include: ['location', 'facets', 'tags'], meta: get_pagination
    end

# Single photo actions

    #GET /api/photos/:id
    def show
      @photo = Photo.find(params[:id])
      render json: @photo, include: ['location', 'facets']
    end

    #DELETE /api/photos/:id
    def destroy
      if @photo.delete
        render json: @photo
      end
    end

    #TODO add id to url
    # /photos/rotate
    def rotate
      rotate_helper([@photo.id], params[:degrees])
      render :json => {:status => true}
    end

    # POST /api/photos/:id/comment/add
    def comment
      @photo.add_comment current_user, params[:comment]
      render json: @photo
    end

    # DELETE /api/photos/:id/comment/delete
    def uncomment
      @photo.uncomment params[:comment_id]
      render json: @photo
    end

    # GET /api/photos/taglist
    def taglist
      tags = Tag.all
      render json: tags
    end

    # POST /api/photos/:id/tag/add
    def tag
      @photo.add_tag current_user, params[:tag]
      render json: @photo
    end

    # /api/photos/:id/tag/delete
    def untag
      @photo.untag params[:tag_id]
      render json: @photo
    end

    # /api/photos/:id/like/toggle
    def like_toggle
      @photo.like_toggle current_user
      render json: @photo
    end

  #Bucket actions

  # /api/photos/bucket
    def bucket
      @bucket = Photo
              .joins(:facets)
              .where('facets.type = ?', 'BucketFacet')
              .where('facets.user_id = ?', current_user) #.includes(:facets, :location)
              .includes(facets: :tag)
              .includes(facets: :user)
              .includes(facets: :comment)
              .includes(location: :city)
              .includes(location: :country)

      render json: @bucket
    end

    # /api/photos/:id/bucket/toggle
    def bucket_toggle
      @photo.bucket_toggle current_user
      render json: @photo
    end

    # /api/photos/bucket/like
    def bucket_like
      photo_ids = params.require(:photoIds)
      @photos = Photo.find(photo_ids).map { |p| p.like current_user }
      json_response(@photos)
    end

    # POST /photos/bucket/rotate/
    def bucket_rotate
      degrees = params.require(:degrees)
      degrees = JSON.parse(degrees)
      @bucket = Photo.joins(:bucket).where('facets.user_id = ?', current_user)
      @bucket.each do |photo|
        photo.rotate(degrees)
      end
      render json: @bucket
    end


    private

    def get_pagination
      {
        total: @photos.total_entries,
        total_pages: @photos.total_pages,
        first_page: @photos.current_page == 1,
        last_page: @photos.next_page.blank?,
        previous_page: @photos.previous_page,
        next_page: @photos.next_page,
        out_of_bounds: @photos.out_of_bounds?,
        offset: @photos.offset
      }
    end

      # Use callbacks to share common setup or constraints between actions.
      def set_photo
        @photo = Photo.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def photo_params
        params.require(:photo).permit(:filename, :date_taken, :path, :file_thumb_path, :file_extension, :file_size, :location_id, :make, :model, :original_height, :original_width, :longitude, :latitude, :tag_id, :photosPerPage)
      end

      def get_album_hash
        set_sort_direction
        set_country
        set_like
        set_tags
      end

      def set_sort_direction()

        if params.has_key? :direction
          case params[:direction]
            when "true"
              @album_hash[:start_date] = params[:startdate]
              # @searchparams[:direction] = "true"
              @order = "asc"
            when "false"
              @album_hash[:end_date] = params[:startdate]
              # @searchparams[:direction] = "false"
              @order = "desc"
          end
        else
          @order = "desc"
          @album_hash[:end_date] = params[:startdate]
          # @searchparams[:direction] = "false"
        end
      end

      def set_country
        if params.has_key? "country"
          @album_hash[:country] = params[:country] unless params[:country] == "-1"
        end
      end

      def set_like
        if params.has_key? "like"
          @album_hash[:like] = params[:like]
        end
      end

      def set_tags
        if params.has_key? "tags"
          if params[:tags].is_a?(Array)
            tags = params[:tags].map{|t| ActsAsTaggableOn::Tag.all.where(name: t).first.id}
            @album_hash[:tags] = tags
          end
        end
      end

  end
