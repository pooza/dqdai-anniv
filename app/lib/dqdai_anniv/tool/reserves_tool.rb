module DqdaiAnniv
  class ReservesTool < Tool
    def uri
      uri = Ginseng::URI.parse(config['/epg_station/url'])
      uri.path = '/api/reserves?isHalfWidth=false'
      return uri
    end

    def fetch
      return JSON.parse(@http.get(uri, {mock: {class: self.class}}).body)['reserves']
    end

    def entries
      return fetch.select {|v| v.to_json.match?(keyword)}.to_h do |row|
        [row.to_json.adler32, self.class.create_entry(row)]
      end
    end

    def path
      return File.join(Environment.dir, 'tmp/cache', "reserves-#{keyword.adler32}.json")
    end

    def help
      return [
        'bin/dqdai-anniv.rb reserves phrase - 新規で予約された、番組情報にphraseを含む番組',
      ]
    end
  end
end
