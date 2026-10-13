module DqdaiAnniv
  class CharacterCalendar < Calendar
    def events(year = DqdaiAnniv.today.year)
      events = {}
      response.map {|v| Character.new(v)}.map {|v| v.events(year)}.each do |entries|
        entries.each do |k, v|
          events[k] ||= []
          events[k] = events[k].concat(v)
        end
      end
      return events
    end
  end
end
