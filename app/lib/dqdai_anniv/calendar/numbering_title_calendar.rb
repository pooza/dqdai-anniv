module DqdaiAnniv
  class NumberingTitleCalendar < Calendar
    def events(year = DqdaiAnniv.today.year)
      events = {}
      response.map {|v| NumberingTitle.new(v)}.each do |v|
        k = v.date.strftime('%m%d')
        events[k] ||= []
        events[k] = events[k].push(v.to_h(year))
      end
      return events
    end
  end
end
