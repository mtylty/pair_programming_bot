require 'rufus-scheduler'

class Scheduler
  def self.start
    scheduler = Rufus::Scheduler.new
    
    # Schedule monthly pairing
    scheduler.cron '0 0 1 * *' do # Run at midnight on the 1st of every month
      PairMatcher.create_monthly_pairs
    end
  end
end

# slack/commands/find_times.rb
class FindTimes < SlackRubyBot::Commands::Base
  command 'find_times' do |client, data, _match|
    pair = Pair.where(
      :matched_at.gt => 30.days.ago,
      :$or => [
        { user1_id: data.user },
        { user2_id: data.user }
      ]
    ).first
    
    return unless pair
    
    user1 = User.find_by(slack_id: pair.user1_id)
    user2 = User.find_by(slack_id: pair.user2_id)
    
    # Find common availability
    start_time = Time.now
    end_time = start_time + 14.days
    
    calendar1 = GoogleCalendar.new(user1.google_credentials)
    calendar2 = GoogleCalendar.new(user2.google_credentials)
    
    slots1 = calendar1.find_available_slots(start_time, end_time)
    slots2 = calendar2.find_available_slots(start_time, end_time)
    
    # Find common slots during working hours
    common_slots = slots1 & slots2
    working_hours_slots = common_slots.select do |slot|
      slot.hour.between?(9, 16) && !slot.saturday? && !slot.sunday?
    end
    
    # Present options
    present_time_options(client, data.channel, working_hours_slots.first(5))
  end
  
  private
  
  def self.present_time_options(client, channel, slots)
    blocks = slots.map.with_index do |slot, index|
      {
        type: "section",
        text: {
          type: "mrkdwn",
          text: "Option #{index + 1}: #{slot.strftime('%B %d, %Y at %I:%M %p')}"
        },
        accessory: {
          type: "button",
          text: {
            type: "plain_text",
            text: "Schedule This Time"
          },
          value: slot.iso8601,
          action_id: "schedule_time_#{index}"
        }
      }
    end
    
    client.chat_postMessage(
      channel: channel,
      text: "Here are some times that work for everyone:",
      blocks: [
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "Here are some times that work for everyone:"
          }
        }
      ] + blocks
    )
  end
end