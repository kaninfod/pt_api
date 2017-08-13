
  class API::PhotosController < ApplicationController
    include BucketActions
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

    #GET /api/photos/
    def index
      # @searchparams = {}
      @album_hash = {}
      @order = "desc"
      get_album_hash
      @album = Album.new(@album_hash)
      #Get photos
      @photos = @album.album_photos.where('photos.status != ? or photos.status is ?', 1, nil).order(date_taken: @order).paginate(:page => params[:page], :per_page=>params[:photosPerPage])
      render json: @photos #, include: ['comments', 'tags', 'like', 'bucket', 'location'] #, each_serializer: PhotoSimpleSerializer
    end

    def show
      render json: @photo #, serializer: PhotoCompleteSerializer
    end

    def destroy
      if @photo.delete
        render json: @photo
      end
    end

    # /photos/rotate
    def rotate
      rotate_helper([@photo.id], params[:degrees])
      render :json => {:status => true}
    end

    # POST /photos/bucket/rotate/
    def rotate_bucket
      @bucket = Photo.joins(:bucket).where('facets.user_id = ?', current_user)
      @bucket.each do |photo|
        photo.rotate(params[:degrees])
      end
      render json: @bucket #, each_serializer: PhotoSimpleSerializer
    end

    # POST /api/photos/:id/comment/add
    def comment
      @photo.add_comment current_user, params[:comment]
      render json: @photo #, serializer: PhotoCompleteSerializer
    end

    # DELETE /api/photos/:id/comment/delete
    def uncomment
      @photo.uncomment params[:comment_id]
      render json: @photo #, serializer: PhotoCompleteSerializer
    end

    # GET /api/photos/taglist
    def taglist
      tags = SourceTag.all
      render json: tags
    end

    # POST /api/photos/:id/tag/add
    def tag
      @photo.add_tag current_user, params[:tag]
      render json: @photo #, serializer: PhotoCompleteSerializer
    end

    # /api/photos/:id/tag/delete
    def untag
      @photo.untag params[:tag_id]
      render json: @photo #, serializer: PhotoCompleteSerializer
    end

    # /api/photos/:id/like/toggle
    def like_toggle
      @photo.like_toggle current_user
      render json: @photo #, serializer: PhotoCompleteSerializer
    end

    # /api/photos/:id/bucket/toggle
    def bucket_toggle
      @photo.bucket_toggle current_user
      render json: @photo #, serializer: PhotoCompleteSerializer
    end

    # /api/photos/bucket
    def bucket
      @bucket = Photo.joins(:bucket).where('facets.user_id = ?', current_user)
      render json: @bucket #, each_serializer: PhotoSimpleSerializer
    end

    private
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
