require 'dotenv/load'
require 'slack-ruby-bot-server'
require_relative 'lib/pair_matcher'
require_relative 'lib/scheduler'

Scheduler.start
SlackRubyBotServer::App.instance.prepare!
SlackRubyBotServer::Service.start!

run SlackRubyBotServer::Api::Web.instance