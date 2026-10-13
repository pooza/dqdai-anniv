module DqdaiAnniv
  class Character < Model
    def initialize(params)
      super
      @events = {}
    end

    def name
      return @params['character']
    end

    # ⚠ **年を引数で受ける (#47)。**`#種﨑敦美生誕祭2026` のように文面が年で変わるので、
    # iCalendar へ来年のぶんを出すときは「今日の年」では作れない。
    def events(year = DqdaiAnniv.today.year)
      @events.clear
      if old_cv_deathday
        push(old_cv_deathday, {name: old_cv, prefix: '旧', type: '命日'}, year)
      elsif old_cv_birthday
        push(old_cv_birthday, {name: old_cv, prefix: '旧', type: '誕生日'}, year)
      end
      if new_cv_deathday
        push(new_cv_deathday, {name: new_cv, type: '命日'}, year)
      elsif new_cv_birthday
        push(new_cv_birthday, {name: new_cv, type: '誕生日'}, year)
      end
      return @events
    end

    def events?
      return events.present?
    end

    private

    def push(date, event, year)
      key = Date.parse("2000/#{date}").strftime('%m%d')
      event[:name] = event[:name].gsub(/[[:blank:]]/, '')
      event[:message] = create_message(event)
      event[:tags] = create_tags(event, year)
      @events[key] ||= []
      @events[key].push(event.except(:name, :prefix, :type))
    end

    def create_tags(event, year)
      tags = Ginseng::Fediverse::TagContainer.new
      tags.push(name)
      tags.push(event[:name])
      if event[:type] == '誕生日'
        tags.push('生誕祭')
        tags.push("#{event[:name]}生誕祭")
        tags.push("#{event[:name]}生誕祭#{year}")
      end
      return tags
    end

    def create_message(event)
      return '%{prefix}「%{character}」役 %{name}さんの%{type}' % {
        prefix: event[:prefix],
        character: name,
        name: event[:name],
        type: event[:type],
      }
    end
  end
end
