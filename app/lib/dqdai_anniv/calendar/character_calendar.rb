module DqdaiAnniv
  class CharacterCalendar < Calendar
    def entries
      entries = {}
      response.map {|v| Character.new(v)}.select(&:events?).map(&:events).each do |events|
        events.each do |k, v|
          entries[k] ||= []
          entries[k] = entries[k].concat(v)
        end
      end
      return entries
    end
  end
end
