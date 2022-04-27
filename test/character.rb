module DqdaiAnniv
  class CharacterTest < TestCase
    def setup
      Timecop.travel(Time.parse('2022/05/28'))
      @crystal = Character.new(
        'character' => '竜水晶',
        'old_cv' => '小林 通孝',
        'old_cv_birthday' => '8/28',
        'new_cv' => '戸田 恵子',
        'new_cv_birthday' => '9/12',
      )
      @dai = Character.new(
        'character' => 'ダイ',
        'old_cv' => '藤田 淑子',
        'old_cv_lastname' => '藤田',
        'old_cv_birthday' => '4/5',
        'old_cv_deathday' => '12/28',
        'new_cv' => '種﨑 敦美',
        'new_cv_lastname' => '種﨑',
        'new_cv_birthday' => '9/27',
      )
      @noevent = Character.new(
        'character' => 'イベントなし太郎',
      )
    end

    def test_name
      assert_equal('竜水晶', @crystal.name)
      assert_equal('ダイ', @dai.name)
      assert_equal('イベントなし太郎', @noevent.name)
    end

    def test_events
      assert_equal({
        '0828' => [{
          message: '旧「竜水晶」役 小林通孝さんの誕生日',
          tags: Set['竜水晶', '小林通孝', '生誕祭', '小林通孝生誕祭', '小林通孝生誕祭2022'],
        }],
        '0912' => [{
          message: '「竜水晶」役 戸田恵子さんの誕生日',
          tags: Set['竜水晶', '戸田恵子', '生誕祭', '戸田恵子生誕祭', '戸田恵子生誕祭2022'],
        }],
      }, @crystal.events)
      assert_equal({
        '0927' => [{
          message: '「ダイ」役 種﨑敦美さんの誕生日',
          tags: Set['ダイ', '種﨑敦美', '生誕祭', '種﨑敦美生誕祭', '種﨑敦美生誕祭2022'],
        }],
        '1228' => [{
          message: '旧「ダイ」役 藤田淑子さんの命日',
          tags: Set['ダイ', '藤田淑子'],
        }],
      }, @dai.events)
      assert_empty(@noevent.events)
    end

    def test_events?
      assert_predicate(@crystal, :events?)
      assert_predicate(@dai, :events?)
      assert_false(@noevent.events?)
    end

    def test_new_cv
      assert_equal('戸田 恵子', @crystal.new_cv)
      assert_equal('種﨑 敦美', @dai.new_cv)
      assert_nil(@noevent.new_cv)
    end

    def test_new_cv_birthday
      assert_equal('9/12', @crystal.new_cv_birthday)
      assert_equal('9/27', @dai.new_cv_birthday)
      assert_nil(@noevent.new_cv_birthday)
    end

    def test_new_cv_deathday
      assert_nil(@crystal.new_cv_deathday)
      assert_nil(@dai.new_cv_deathday)
      assert_nil(@noevent.new_cv_deathday)
    end

    def test_old_cv
      assert_equal('小林 通孝', @crystal.old_cv)
      assert_equal('藤田 淑子', @dai.old_cv)
      assert_nil(@noevent.old_cv)
    end

    def test_old_cv_birthday
      assert_equal('8/28', @crystal.old_cv_birthday)
      assert_equal('4/5', @dai.old_cv_birthday)
      assert_nil(@noevent.old_cv_birthday)
    end

    def test_old_cv_deathday
      assert_nil(@crystal.old_cv_deathday)
      assert_equal('12/28', @dai.old_cv_deathday)
      assert_nil(@noevent.old_cv_deathday)
    end
  end
end
