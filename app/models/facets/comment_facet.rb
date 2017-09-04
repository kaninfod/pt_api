class CommentFacet < Facet
  delegate :name, :to => :comment
  include ActionView::Helpers::DateHelper

  def created
    time_ago_in_words(self.created_at)
  end
end
