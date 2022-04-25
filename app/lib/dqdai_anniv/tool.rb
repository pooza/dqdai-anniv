module DqdaiAnniv
  class Tool
    include Package
    attr_accessor :keyword

    def initialize
      @http = HTTP.new
    end

    def exec(args = {})
      @keyword = args.first
      dest = entries.reject {|id, _| prev.member?(id)}.transform_values(&:to_yaml)
      save
      return dest.values.join
    end

    def uri
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    def fetch
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    def path
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    def save
      File.write(path, entries.to_json)
    end

    def load
      @prev ||= JSON.parse(File.read(path))
      return @prev
    rescue
      return {}
    end

    alias prev load

    def help
      return ["-- #{self.class} のヘルプは未定義 --"]
    end

    def self.create_entry(row)
      return {
        '題名' => row['name'].gsub(/\R/, "\n"),
        '開始' => row['startAt'].to_time.strftime('%m/%d %H:%M'),
        '終了' => row['endAt'].to_time.strftime('%m/%d %H:%M'),
        '概要' => row['description']&.gsub(/\R/, "\n"),
      }.compact.reject {|_k, v| v.is_a?(String) && v.match?(/^[[:blank:]]+$/)}
    end

    def self.create(name)
      return "DqdaiAnniv::#{name.camelize}Tool".constantize.new
    end

    def self.all
      return enum_for(__method__) unless block_given?
      config['/tools'].each do |name|
        yield create(name)
      end
    end
  end
end
