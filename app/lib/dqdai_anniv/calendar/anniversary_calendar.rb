module DqdaiAnniv
  class AnniversaryCalendar < Calendar
    def events
      events = {}
      response.each do |event|
        key = Date.parse("2000/#{event['date']}").strftime('%m%d')
        events[key] ||= []
        events[key].push(message: event['title'], tags: create_tags(event))
      end
      return events
    end

    private

    def create_tags(event)
      tags = Ginseng::Fediverse::TagContainer.new(event['tags'] || [])
      if tag = tags.find {|t| t.end_with?('生誕祭')}
        tags.push('生誕祭')
        tags.push("#{tag}#{Date.today.year}")
      elsif tag = tags.find {|t| t.match?(/(祭|まつり)/)}
        tags.push("#{tag}#{Date.today.year}")
      end
      return tags
    end
  end
end
