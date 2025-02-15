module DqdaiAnniv
  class Character
    include Package

    def initialize(params)
      @params = params
      @events = {}
    end

    def name
      return @params['character']
    end

    def events
      @events.clear
      if old_cv_deathday
        push(old_cv_deathday, {name: old_cv, prefix: '旧', type: '命日'})
      elsif old_cv_birthday
        push(old_cv_birthday, {name: old_cv, prefix: '旧', type: '誕生日'})
      end
      if new_cv_deathday
        push(new_cv_deathday, {name: new_cv, type: '命日'})
      elsif new_cv_birthday
        push(new_cv_birthday, {name: new_cv, type: '誕生日'})
      end
      return @events
    end

    def events?
      return events.present?
    end

    def new_cv
      return @params['new_cv']
    end

    def new_cv_birthday
      return @params['new_cv_birthday']
    end

    def new_cv_deathday
      return @params['new_cv_deathday']
    end

    def old_cv
      return @params['old_cv']
    end

    def old_cv_birthday
      return @params['old_cv_birthday']
    end

    def old_cv_deathday
      return @params['old_cv_deathday']
    end

    private

    def push(date, event)
      key = Date.parse("2000/#{date}").strftime('%m%d')
      event[:name] = event[:name].gsub(/[[:blank:]]/, '')
      event[:message] = create_message(event)
      event[:tags] = create_tags(event)
      @events[key] ||= []
      @events[key].push(event.except(:name, :prefix, :type))
    end

    def create_tags(event)
      tags = Ginseng::Fediverse::TagContainer.new
      tags.push(name)
      tags.push(event[:name])
      if event[:type] == '誕生日'
        tags.push('生誕祭')
        tags.push("#{event[:name]}生誕祭")
        tags.push("#{event[:name]}生誕祭#{Date.today.year}")
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
