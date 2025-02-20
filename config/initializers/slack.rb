SlackRubyBotServer.configure do |config|
  config.oauth_version = :v2
  config.oauth_scope = ['chat:write', 'im:write', 'groups:write', 'channels:read', 'users:read']
  config.database_adapter = :mongoid
end