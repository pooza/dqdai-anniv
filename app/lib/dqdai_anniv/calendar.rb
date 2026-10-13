module DqdaiAnniv
  class Calendar
    include Package

    def initialize
      @http = HTTP.new
      # ⚠ **取得側だけ 404 の再送を開ける (#38)。**GAS が間欠的に 404 を返す。
      # HTTP の既定は変えない (HTTP#retry_not_found のコメント参照)。
      @http.retry_not_found = true
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

    # 🔴 **空の一覧・一覧でない応答は例外にする (#49)。**
    #
    # ⚠⚠ 取得先（GAS）がシートを読めずに空の配列を返すと、以前は「記念日が 1 件も無い」として
    # 正常終了していた。`--ics` なら予定 0 件のカレンダー、文章モードなら何も出さない。
    # tomato-shrieker はどちらも「該当なし」の success として扱うので、**告知が 1 件も出ない
    # まま緑になる**。元のデータが空になることは無いので、空は壊れていると読む。
    # ⚠ 見るのは応答（元のデータ）で、その日・その年に該当があるかではない。
    def response
      @response ||= @http.get(uri).parsed_response
      unless @response.is_a?(Array) && @response.present?
        raise "#{name}: empty or unexpected response from #{uri}"
      end
      return @response
    end

    def events(_year = DqdaiAnniv.today.year)
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    def messages
      return events.to_h {|k, events| [k, events.map {|v| create_message(k, v)}]}
    end

    # 記念日を iCalendar で返す (#47)。事前告知（N 日前から当日まで）の日数を数えるのは
    # tomato-shrieker の `IcalendarSource` に任せる。
    #
    # ⚠ **`RRULE` を使わず、年ごとに具体的な日付で出す。**「34周年」や
    # `#種﨑敦美生誕祭2026` は年で変わるので、繰り返しにすると文面を作れない。
    # ⚠ **今年と来年のぶんを出す。**tomato-shrieker は開始日の N 日前から拾うので、
    # 年末には 1 月の予定が見えている必要がある。
    def ical(years = [DqdaiAnniv.today.year, DqdaiAnniv.today.year + 1])
      ical = Icalendar::Calendar.new
      ical.prodid = "-//#{Package.name}//#{name}//JA"
      years.each do |year|
        events(year).sort.each do |key, entries|
          next unless date = create_date(year, key)
          entries.each_with_index {|entry, i| ical.add_event(create_ical_event(date, entry, i))}
        end
      end
      return ical
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

    private

    # ⚠ 2/29 の記念日は、閏年でない年には出さない（`Date.new` が例外になる）。
    def create_date(year, key)
      month = key[0, 2].to_i
      day = key[2, 2].to_i
      return nil unless Date.valid_date?(year, month, day)
      return Date.new(year, month, day)
    end

    # ⚠ **終了日（`DTEND`）を書かない。**終日の予定の `DTEND` は「翌日」と書くのが規格だが、
    # tomato-shrieker はそれを Google カレンダーのときしか 1 日戻さない。書かなければ
    # 開始日と同じ日として扱われる。
    def create_ical_event(date, entry, index)
      event = Icalendar::Event.new
      event.uid = "#{name}-#{date.strftime('%Y%m%d')}-#{index}@#{Package.name}"
      event.dtstart = Icalendar::Values::Date.new(date)
      event.summary = entry[:message]
      event.description = entry[:tags].map(&:to_hashtag).join(' ') if entry[:tags].present?
      return event
    end

    def create_message(key, event)
      date = Date.parse("#{DqdaiAnniv.today.year}#{key}")
      lines = ["#{date.month}月#{date.day}日は、#{event[:message]}。"]
      lines.push(event[:tags].map(&:to_hashtag).join(' ')) if event[:tags].present?
      return lines.join("\n")
    end
  end
end
