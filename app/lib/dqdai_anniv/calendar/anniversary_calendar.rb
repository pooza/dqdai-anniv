module DqdaiAnniv
  class AnniversaryCalendar < Calendar
    def entries
      entries = {}
      fetch.each do |entry|
        key = Date.parse("2000/#{entry['date']}").strftime('%m%d')
        tags = entry['tags'] || []
        if tag = tags.find {|v| v.end_with?('生誕祭')}
          tags.push('生誕祭')
          tags.push("#{tag}#{Date.today.year}")
        end
        entries[key] ||= []
        entries[key].push(message: entry['title'], tags: tags.uniq)
      end
      return entries
    end
  end
end
