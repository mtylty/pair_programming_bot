class PairMatcher
  def self.create_monthly_pairs
    channel_members = fetch_channel_members
    shuffled_members = channel_members.shuffle
    
    pairs = []
    shuffled_members.each_slice(2) do |pair|
      pairs << Pair.create!(
        user1_id: pair[0],
        user2_id: pair[1],
        matched_at: Time.now
      )
    end
    
    # Handle odd number of members
    if shuffled_members.length.odd?
      last_pair = pairs.sample
      last_pair.update!(user2_id: shuffled_members.last)
    end
    
    pairs.each { |pair| notify_pair(pair) }
  end
  
  private
  
  def self.fetch_channel_members
    client = Slack::Web::Client.new
    result = client.conversations_members(
      channel: ENV['PAIR_PROGRAMMING_CHANNEL_ID']
    )
    result.members
  end
  
  def self.notify_pair(pair)
    client = Slack::Web::Client.new
    
    # Open group DM
    conversation = client.conversations_open(
      users: [pair.user1_id, pair.user2_id].join(',')
    )
    
    # Send initial message
    client.chat_postMessage(
      channel: conversation.channel.id,
      text: "Hello! You've been matched for a pair programming session! 🎉",
      blocks: [
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "Hello! You've been matched for a pair programming session! 🎉"
          }
        },
        {
          type: "actions",
          elements: [
            {
              type: "button",
              text: {
                type: "plain_text",
                text: "Find Available Times"
              },
              action_id: "find_times"
            }
          ]
        }
      ]
    )
  end
end