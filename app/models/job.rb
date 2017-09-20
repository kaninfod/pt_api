class Job < ActiveRecord::Base
  serialize :arguments, Array
  belongs_to :jobable, polymorphic: true, required:false
end
