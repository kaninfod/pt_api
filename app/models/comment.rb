class Comment < Facet
  belongs_to :photo
  belongs_to :user
  # belongs_to :source_comment, optional: true, class_name: 'SourceComment', foreign_key: :source_id

  delegate :name, :to => :source_comment

  include ActionView::Helpers::DateHelper

  def created
    time_ago_in_words(self.created_at)
  end
end
