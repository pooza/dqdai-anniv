module DqdaiAnniv
  class NumberingTitle < Model
    def message
      return "「#{title}」の発売日から#{anniversary}周年"
    end

    def date
      return Time.parse(@params['date']).getlocal.to_date
    end

    def anniversary
      return Date.parse("#{Date.today.year}/#{date.strftime('%m/%d')}").year - date.year
    end

    def tags
      return Ginseng::Fediverse::TagContainer.new(@params['tags'])
    end

    def to_h
      return {date:, message:, tags:}
    end
  end
end
