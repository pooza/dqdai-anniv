module DqdaiAnniv
  class RecordingTool < Tool
    def uri
      uri = Ginseng::URI.parse(config['/epg_station/url'])
      uri.path = '/api/recording?isHalfWidth=false'
      return uri
    end

    def fetch
      return JSON.parse(@http.get(uri, {mock: {class: self.class}}).body)['records']
    end

    def entries
      return fetch.to_h do |row|
        [row.to_json.adler32, self.class.create_entry(row)]
      end
    end

    def path
      return File.join(Environment.dir, 'tmp/cache', 'recording.json')
    end

    def help
      return [
        'bin/dqdai-anniv.rb recording - 録画中の番組',
      ]
    end
  end
end
