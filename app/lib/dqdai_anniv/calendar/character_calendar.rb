module DqdaiAnniv
  class CharacterCalendar < Calendar
    def events
      events = {}
      response.map {|v| Character.new(v)}.select(&:events?).map(&:events).each do |entries|
        entries.each do |k, v|
          events[k] ||= []
          events[k] = events[k].concat(v)
        end
      end
      return events
    end
  end
end
