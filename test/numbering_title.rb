module DqdaiAnniv
  class NumberingTitleTest < TestCase
    def setup
      @dq4 = NumberingTitle.new(
        'title' => 'ドラゴンクエストIV 導かれし者たち',
        'date' => '1990-02-10T15:00:00.000Z',
      )
      @dq10 = NumberingTitle.new(
        'title' => 'ドラゴンクエストX 目覚めし五つの種族 オンライン',
        'date' => '2012-08-01T15:00:00.000Z',
      )
    end

    def test_title
      assert_equal('ドラゴンクエストIV 導かれし者たち', @dq4.title)
      assert_equal('ドラゴンクエストX 目覚めし五つの種族 オンライン', @dq10.title)
    end

    # #47: 周年は渡した年で数える。
    def test_anniversary
      Timecop.travel(Time.parse('2026/05/28 12:00:00 +09:00'))

      assert_equal(36, @dq4.anniversary)
      assert_equal(37, @dq4.anniversary(2027))
      assert_equal('「ドラゴンクエストIV 導かれし者たち」の発売日から37周年', @dq4.message(2027))
      assert_equal(@dq4.message(2027), @dq4.to_h(2027)[:message])
    end

    def test_date
      assert_equal(Date.parse('1990/2/11'), @dq4.date)
      assert_equal(Date.parse('2012/8/2'), @dq10.date)
    end
  end
end
