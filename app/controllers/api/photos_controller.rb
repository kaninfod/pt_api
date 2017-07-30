module Api
  class PhotosController < ApplicationController
    include BucketActions
    set_pagination_headers :photos, only: [:index]
    before_action :set_photo, only: [
      :destroy,
      :rotate,
      :show,
      :add_to_album,
      :comment, :uncomment,
      :like, :unlike,
      :bucket, :unbucket,
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
      @photos = @album.album_photos.where('photos.status != ? or photos.status is ?', 1, nil).order(date_taken: @order).paginate(:page => params[:page], :per_page=>60)
      render json: @photos, each_serializer: PhotoSimpleSerializer
    end

    def show
      # @photo = Photo.find_by_id(params[:id]).includes(:tags)
      render json: @photo, serializer: PhotoCompleteSerializer
    end

    def destroy
      if @photo.delete
        render json: {:status=> 200, photo_id: photo.id}
      end
    end

    def rotate
      # @photo = Photo.find(params[:id])
      rotate_helper([@photo.id], params[:degrees])
      render :json => {:status => true}
    end

    # /api/photos/:id/comment/add
    def comment
      @photo.add_comment current_user, params[:comment]
      render json: @photo, serializer: PhotoCompleteSerializer
    end

    # /api/photos/:id/comment/delete
    def uncomment
      @photo.uncomment params[:comment_id]
      render json: @photo, serializer: PhotoCompleteSerializer
    end

    # /api/photos/tags
    def tags
      tags = SourceTag.all
      render json: tags
    end

    # /api/photos/:id/tag/add
    def tag
      @photo.add_tag current_user, params[:tag]
      render json: @photo, serializer: PhotoCompleteSerializer
    end

    # /api/photos/:id/tag/delete
    def untag
      @photo.untag params[:tag_id]
      render json: @photo, serializer: PhotoCompleteSerializer
    end

    # /api/photos/:id/like/add
    def like
      @photo.add_like current_user
      render json: @photo, serializer: PhotoCompleteSerializer
    end

    # /api/photos/:id/like/delete
    def unlike
      @photo.unlike current_user
      render json: @photo, serializer: PhotoCompleteSerializer
    end

    # /api/photos/:id/bucket/add
    def bucket
      @photo = @photo.add_bucket current_user
      render json: @photo, serializer: PhotoCompleteSerializer
    end

    # /api/photos/:id/unbucket/delete
    def unbucket
      @photo.unbucket current_user
      render json: @photo, serializer: PhotoCompleteSerializer
    end

    private

      # Use callbacks to share common setup or constraints between actions.
      def set_photo
        @photo = Photo.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def photo_params
        params.require(:photo).permit(:filename, :date_taken, :path, :file_thumb_path, :file_extension, :file_size, :location_id, :make, :model, :original_height, :original_width, :longitude, :latitude)
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
end



    # def add_comment
    #   if params.has_key? "comment"
    #     comment = add_comment_helper(@photo.id, params[:comment])
    #     @comments = Photo.find(@photo.id).comments
    #     render :partial => 'comments', locals: {comments: @comments}
    #   end
    # end
    #
    # def like
    #   if current_user.voted_for? @photo
    #     @photo.unliked_by current_user
    #   else
    #     @photo.liked_by current_user
    #   end
    #   render :json => {:likes => @photo.votes_for.size, :liked_by_current_user => (current_user.voted_for? @photo)}
    # end

    # #GET /api/photos/taglist
    # def taglist
    #   @taglist = ActsAsTaggableOn::Tag.all
    #   render json: @taglist, each_serializer: TaglistSerializer
    # end

    # def addtag
    #   if params[:name][0,1] == "@"
    #     @photo.objective_list.add params[:name]
    #   else
    #     @photo.tag_list.add params[:name]
    #   end
    #
    #   if @photo.save
    #     render :json => {:tags => @photo.tags}
    #   else
    #     render :status => "500"
    #   end
    # end
    #
    # def removetag
    #   # photo = Photo.find params[:id]
    #
    #   if params[:name][0,1] == "@"
    #     @photo.objective_list.remove params[:name]
    #   else
    #     @photo.tag_list.remove params[:name]
    #   end
    #
    #   if @photo.save
    #     render :json => {:tags => @photo.tags}
    #   else
    #     render :status => "500"
    #   end
    # end
