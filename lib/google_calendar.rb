require 'google/apis/calendar_v3'

class GoogleCalendar
  def initialize(credentials)
    @calendar = Google::Apis::CalendarV3::CalendarService.new
    @calendar.authorization = Google::Auth::UserRefreshCredentials.new(
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      refresh_token: credentials['refresh_token'],
      scope: ['https://www.googleapis.com/auth/calendar']
    )
  end
  
  def find_available_slots(start_time, end_time)
    free_busy_request = Google::Apis::CalendarV3::FreeBusyRequest.new(
      time_min: start_time.iso8601,
      time_max: end_time.iso8601,
      items: [{ id: 'primary' }]
    )
    
    result = @calendar.query_freebusy(free_busy_request)
    busy_slots = result.calendars['primary'].busy
    
    # Convert busy slots to free slots
    free_slots = []
    current_time = start_time
    
    while current_time < end_time
      slot_end = current_time + 1.hour
      is_busy = busy_slots.any? do |busy|
        busy_start = Time.parse(busy.start)
        busy_end = Time.parse(busy.end)
        (current_time >= busy_start && current_time < busy_end) ||
          (slot_end > busy_start && slot_end <= busy_end)
      end
      
      free_slots << current_time unless is_busy
      current_time += 1.hour
    end
    
    free_slots
  end
  
  def create_event(start_time, end_time, attendees)
    event = Google::Apis::CalendarV3::Event.new(
      summary: 'Pair Programming Session',
      description: 'Monthly pair programming session to share knowledge and collaborate.',
      start: { date_time: start_time.iso8601 },
      end: { date_time: end_time.iso8601 },
      attendees: attendees.map { |email| { email: email } }
    )
    
    @calendar.insert_event('primary', event)
  end
end