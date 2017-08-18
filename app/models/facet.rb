class Facet < ApplicationRecord
  belongs_to :photo
  belongs_to :user
  belongs_to :source_comment, default: -> {SourceComment.first}
  belongs_to :source_tag, default: -> {SourceTag.first}
end
