class Comment < Facet
  belongs_to :photo
  belongs_to :user
  belongs_to :source_comment, default: -> {SourceComment.first}

  delegate :name, :to => :source_comment
  validates :user_id, uniqueness: { scope: [:photo, :source_comment_id],
    message: "This comment exists already" }
  include ActionView::Helpers::DateHelper

  def created
    time_ago_in_words(self.created_at)
  end
end
