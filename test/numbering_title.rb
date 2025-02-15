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

    def test_date
      assert_equal(Date.parse('1990/2/10'), @dq4.date)
      assert_equal(Date.parse('2012/8/1'), @dq10.date)
    end
  end
end
