module DqdaiAnniv
  # 記念日の iCalendar 出力 (#47)。
  # ⚠ 取得先（mstdn.delmulin.com）へはつながない。応答を差し込んで、日付と文面だけを見る。
  class IcalTest < TestCase
    def setup
      Timecop.travel(Time.parse('2026/12/30 12:00:00 +09:00'))
    end

    def test_numbering_title
      ical = numbering_title_calendar.ical
      events = ical.events.to_h {|v| [v.dtstart.to_s, v]}

      # 今年と来年のぶん。年末に 1 月の予定が見えていること。
      assert_equal(['2026-02-11', '2026-09-27', '2027-02-11', '2027-09-27'], events.keys.sort)
      assert_equal('「ドラゴンクエストIV 導かれし者たち」の発売日から37周年', events['2027-02-11'].summary)
      assert_equal('「ドラゴンクエストV 天空の花嫁」の発売日から34周年', events['2026-09-27'].summary)
      assert_equal('#dq5', events['2026-09-27'].description)
    end

    def test_character
      events = character_calendar.ical.events.to_h {|v| [v.dtstart.to_s, v]}

      assert_equal(['2026-09-27', '2026-12-28', '2027-09-27', '2027-12-28'], events.keys.sort)
      assert_equal('「ダイ」役 種﨑敦美さんの誕生日', events['2027-09-27'].summary)
      # 年で変わるタグは、その予定の年で作る。
      assert_includes(events['2026-09-27'].description.split, '#種﨑敦美生誕祭2026')
      assert_includes(events['2027-09-27'].description.split, '#種﨑敦美生誕祭2027')
      assert_equal('旧「ダイ」役 藤田淑子さんの命日', events['2026-12-28'].summary)
    end

    # 終日の予定で、繰り返し（RRULE）と終了日は書かない。
    def test_all_day_without_rrule
      character_calendar.ical.events.each do |event|
        assert_kind_of(Icalendar::Values::Date, event.dtstart)
        assert_nil(event.dtend)
        assert_empty(event.rrule)
      end
    end

    def test_uid_is_unique
      uids = character_calendar.ical.events.map {|v| v.uid.to_s}

      assert_equal(uids.uniq, uids)
    end

    # 2/29 の記念日は閏年にだけ出す。
    def test_leap_day
      calendar = Calendar.create('numbering_title')
      calendar.instance_variable_set(:@response, [
        {'title' => '閏日のタイトル', 'date' => '2000-02-28T15:00:00.000Z', 'tags' => []},
      ])

      assert_empty(calendar.ical([2026, 2027]).events)
      assert_equal(['2028-02-29'], calendar.ical([2028]).events.map {|v| v.dtstart.to_s})
    end

    # 🔴 **#49: 取得先が空の一覧を返したら、予定 0 件で正常終了せずに例外にする。**
    #
    # ⚠⚠ tomato-shrieker は予定 0 件のカレンダーを「該当なし」の success として扱うので、
    # 通してしまうと告知が 1 件も出ないまま緑になる。⚠ 一覧でない応答（エラーの Hash・HTML）も
    # 同じ扱い（以前は `NoMethodError` で落ちていた）。
    def test_empty_response_is_error
      responses = [[], {}, {'error' => 'x'}, '<html>error</html>', nil]
      responses.product(['character', 'numbering_title']).each do |response, name|
        calendar = Calendar.create(name)
        calendar.instance_variable_set(:@response, response)
        # ⚠ nil だと `||=` が実際に取りに行くので、取得を差し替えておく。
        calendar.instance_variable_set(:@http, FakeHTTP.new(response))
        error = assert_raise(RuntimeError, response.inspect) {calendar.ical}

        assert_include(error.message, "#{name}: empty or unexpected response")
        assert_raise(RuntimeError) {calendar.messages}
      end
    end

    # 応答を差し替えるための HTTP。
    class FakeHTTP
      def initialize(response)
        @response = response
      end

      def get(_uri)
        return Struct.new(:parsed_response).new(@response)
      end
    end

    # 該当が無くても、空の VCALENDAR を返す。
    def test_empty
      calendar = Calendar.create('character')
      calendar.instance_variable_set(:@response, [{'character' => 'イベントなし太郎'}])
      text = calendar.ical.to_ical

      assert_empty(calendar.ical.events)
      assert_match(/\ABEGIN:VCALENDAR/, text)
      assert_match(/END:VCALENDAR\s*\z/, text)
      assert_equal(1, Icalendar::Calendar.parse(text).count)
    end

    # 出力を読み戻しても同じ予定になる（折り返し・エスケープを含めて）。
    def test_round_trip
      parsed = Icalendar::Calendar.parse(character_calendar.ical.to_ical).first

      assert_equal(4, parsed.events.count)
      assert_equal(
        '#ダイ #種﨑敦美 #生誕祭 #種﨑敦美生誕祭 #種﨑敦美生誕祭2026',
        parsed.events.find {|v| v.dtstart.to_s == '2026-09-27'}.description.to_s,
      )
    end

    private

    def numbering_title_calendar
      calendar = Calendar.create('numbering_title')
      calendar.instance_variable_set(:@response, [
        {'title' => 'ドラゴンクエストIV 導かれし者たち', 'date' => '1990-02-10T15:00:00.000Z', 'tags' => ['dq4']},
        {'title' => 'ドラゴンクエストV 天空の花嫁', 'date' => '1992-09-26T15:00:00.000Z', 'tags' => ['dq5']},
      ])
      return calendar
    end

    def character_calendar
      calendar = Calendar.create('character')
      calendar.instance_variable_set(:@response, [
        {
          'character' => 'ダイ',
          'old_cv' => '藤田 淑子', 'old_cv_birthday' => '4/5', 'old_cv_deathday' => '12/28',
          'new_cv' => '種﨑 敦美', 'new_cv_birthday' => '9/27'
        },
        {'character' => 'イベントなし太郎'},
      ])
      return calendar
    end
  end
end
