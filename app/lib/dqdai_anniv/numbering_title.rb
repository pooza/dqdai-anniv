module DqdaiAnniv
  class NumberingTitle
    include Package

    def initialize(params)
      @params = params
    end

    def title
      return @params['title']
    end

    alias name title

    def message
      return "「#{name}」の発売日 （#{anniversary}周年）"
    end

    def date
      return Date.parse(@params['date'])
    end

    def anniversary
      return Date.parse("#{Date.today.year}/#{date.strftime('%m/%d')}").year - date.year
    end

    def tags
      return Ginseng::Fediverse::TagContainer.new(@params['tags'])
    end

    def to_h
      return {message:, tags:}
    end
  end
end
