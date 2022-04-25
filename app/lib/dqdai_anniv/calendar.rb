module DqdaiAnniv
  class Calendar
    include Package

    def initialize
      @http = HTTP.new
      @params = config['/calendar'].find {|c| c['name'] == name}
      @result = nil
    end

    def name
      return self.class.to_s.match(/DqdaiAnniv::(.*)Calendar/)[1].underscore
    end

    def uri
      @uri ||= Ginseng::URI.parse(@params['url'])
      return @uri
    end

    def response
      @response ||= @http.get(uri).parsed_response
      return @response
    end

    def events
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    def messages
      return events.to_h {|k, events| [k, events.map {|v| create_message(k, v)}]}
    end

    def create_message(key, event)
      date = Date.parse("#{Date.today.year}#{key}")
      lines = ["#{date.month}月#{date.day}日は、#{event[:message]}。"]
      lines.push(event[:tags].map(&:to_hashtag).join(' ')) if event[:tags].present?
      return lines.join("\n")
    end

    def self.all
      return enum_for(__method__) unless block_given?
      config['/calendar'].each do |name|
        yield Calendar.create(name['name'])
      end
    end

    def self.create(name)
      return "DqdaiAnniv::#{name.camelize}Calendar".constantize.new
    end
  end
end
