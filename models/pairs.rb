class Pair
  include Mongoid::Document
  
  field :user1_id, type: String
  field :user2_id, type: String
  field :matched_at, type: Time
  field :meeting_scheduled, type: Boolean, default: false
  
  index({ matched_at: 1 })
end