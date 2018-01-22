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
    before_action :get_bucket, only: [
      :bucket,
      :bucket_like,
      :bucket_unlike,
      :bucket_comment,
      :bucket_uncomment,
      :bucket_tag,
      :bucket_untag,
      :bucket_rotate,
      :bucket_add_to_album,
    ]

    #GET /api/photos/
    def index

      @album_hash = {}
      @order = "desc"
      get_album_hash
      @album = Album.new(@album_hash)
      #Get photos
      @photos = @album
              .album_photos#.where('photos.status != ? or photos.status is ?', 1, nil)
              .includes(:facets)
              .order(date_taken: @order)
              .paginate(:page => params[:page], :per_page=>params[:photosPerPage])
            render json: @photos, each_serializer: PhotoListSerializer, meta: get_pagination, include: "facets"
    end

# Single photo actions

    #GET /api/photos/:id
    def show
      @photo = Photo.where(id:params[:id])
        .includes(facets: :user)
        .includes(facets: :comment)
        .includes(facets: :tag)
        .includes(facets: :album)
      render json: @photo, include: ['location', 'facets', 'commnets']
    end

    #DELETE /api/photos/:id
    def destroy
      if @photo.delete
        render json: @photo
      end
    end

    # /photos/rotate
    def rotate
      @photo.rotate params[:degrees]
      render json: @photo
    end

    # POST /api/photos/:id/add_to_album
    def add_to_album
      @photo.add_to_album current_user, params[:album_id]
      render json: @photo
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
      render json: @bucket, each_serializer: PhotoListSerializer
    end

    # /api/photos/:id/bucket/toggle
    def bucket_toggle
      @photo.bucket_toggle current_user
      render json: @photo
    end

    # /api/photos/bucket/clear
    def bucket_clear
      BucketFacet.where(user: current_user).destroy_all
      # @photo.bucket_clear current_user
      render json: get_bucket
    end

    # /api/photos/bucket/like
    def bucket_like
      @bucket.each do |photo|
        photo.like current_user
      end
      render json: get_bucket
    end

    # /api/photos/bucket/unlike
    def bucket_unlike
      @bucket.each do |photo|
        photo.unlike current_user
      end
      render json: get_bucket
    end

    # POST /photos/bucket/rotate/
    def bucket_rotate
      degrees = params.require(:degrees)

      @bucket.each do |photo|
        photo.rotate(degrees)
      end
      render json: get_bucket
    end

    # POST /photos/bucket/add_to_album/
    def bucket_add_to_album
      album_id = params.require(:album_id)

      @bucket.each do |photo|
        photo.add_to_album album_id
      end
      render json: get_bucket
    end

    # POST /api/photos/bucket/tag/add
    def bucket_tag
      tag = params.require(:tag)
      @bucket.each do |photo|
        photo.add_tag current_user, tag
      end
      render json: get_bucket
    end

    # /api/photos/bucket/tag/delete
    def bucket_untag
      #tag_id is a facet_id!!
      tag_id = params.require(:tag_id)
      @bucket.each do |photo|
        photo.untag tag_id
      end
      render json: get_bucket
    end

    # POST /api/photos/bucket/comment/add
    def bucket_comment
      comment = params.require(:comment)
      @bucket.each do |photo|
        photo.add_comment current_user, comment
      end
      render json: get_bucket
    end

    # DELETE /api/photos/bucket/comment/delete
    def bucket_uncomment
      #comment_id is a facet_id
      comment_id = params.require(:comment_id)
      @bucket.each do |photo|
        photo.uncomment comment_id
      end
      render json: get_bucket
    end

    private

    def get_bucket
      @bucket = Photo
              .joins(:facets)
              .where('facets.type = ?', 'BucketFacet')
              .where('facets.user_id = ?', current_user) #.includes(:facets, :location)
              .includes(facets: :location)
              .includes(facets: :tag)
              .includes(facets: :user)
              .includes(facets: :comment)
              .includes(location: :city)
              .includes(location: :country)

      # @bucket = BucketFacet.where(user: current_user)
    end

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
