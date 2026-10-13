module DqdaiAnniv
  class NumberingTitle < Model
    def message(year = DqdaiAnniv.today.year)
      return "「#{title}」の発売日から#{anniversary(year)}周年"
    end

    def date
      return Time.parse(@params['date']).getlocal(TIMEZONE).to_date
    end

    def anniversary(year = DqdaiAnniv.today.year)
      return year - date.year
    end

    def tags
      return Ginseng::Fediverse::TagContainer.new(@params['tags'])
    end

    def to_h(year = DqdaiAnniv.today.year)
      return {date:, message: message(year), tags:}
    end
  end
end
