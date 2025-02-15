module DqdaiAnniv
  class NumberingTitleCalendarTest < TestCase
    def setup
      @calendar = Calendar.create('numbering_title')
    end

    def test_name
      assert_equal('numbering_title', @calendar.name)
    end

    def test_uri
      assert_kind_of(Ginseng::URI, @calendar.uri)
    end

    def test_events
      assert_kind_of(Hash, @calendar.events)
      @calendar.events.each do |date, events|
        assert_kind_of(String, date)
        assert_kind_of(Date, Date.parse("2000#{date}"))
        assert_kind_of(Array, events)
        events.each do |event|
          assert_kind_of(String, event[:message])
          assert_kind_of(Ginseng::Fediverse::TagContainer, event[:tags])
        end
      end
    end
  end
end
