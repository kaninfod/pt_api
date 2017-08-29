class Facet < ApplicationRecord
  belongs_to :photo
  belongs_to :user
  belongs_to :source_comment, optional: true, class_name: 'SourceComment', foreign_key: :source_id
  belongs_to :source_tag, optional: true, class_name: 'SourceTag', foreign_key: :source_id
  # belongs_to :album, default: -> {Album.first}
end
