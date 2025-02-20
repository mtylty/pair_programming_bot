class User
  include Mongoid::Document
  
  field :slack_id, type: String
  field :google_credentials, type: Hash
  
  index({ slack_id: 1 }, { unique: true })
end