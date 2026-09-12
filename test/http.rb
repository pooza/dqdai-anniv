module DqdaiAnniv
  class HTTPTest < TestCase
    URL = 'https://example.com/calendar.json'.freeze

    # ⚠ TestCase は WebMock::API を include しているだけで enable! を呼んでいない。
    # 有効化しないと stub_request は何も傍受せず、実 example.com の応答を拾って
    # 通ってしまう。⚠ **全体で有効化すると実 API を叩いている既存テスト
    # (Calendar 系) が全部落ちる**ので、このテストケースの中だけで開閉する。
    def setup
      WebMock.enable!
      WebMock.disable_net_connect!
    end

    def teardown
      WebMock.allow_net_connect!
      WebMock.disable!
      super
    end

    # #38: カレンダーの URL が飛ぶ先の GAS は、生きていても間欠的に 404 を返す。
    def test_retries_not_found_when_enabled
      stub = stub_request(:get, URL).to_return({status: 404}, {status: 200, body: '{}'})
      http = HTTP.new
      http.retry_not_found = true

      assert_equal('{}', http.get(URL).body)
      assert_requested(stub, times: 2)
    end

    # ⚠ 既定は再送しない。ginseng-core の「恒久的な失敗を再送しない」方針を
    # 巻き戻さない。本当に消えた URL まで retry_limit 回叩くことになる。
    def test_does_not_retry_not_found_by_default
      stub = stub_request(:get, URL).to_return({status: 404}, {status: 200, body: '{}'})

      assert_raise(Ginseng::GatewayError) {HTTP.new.get(URL)}
      assert_requested(stub, times: 1)
    end

    # 404 だけを開ける。401 / 403 まで再送すると、待ち時間とログが retry_limit 倍になる
    def test_retry_not_found_does_not_widen_other_4xx
      stub = stub_request(:get, URL).to_return({status: 403}, {status: 200, body: '{}'})
      http = HTTP.new
      http.retry_not_found = true

      assert_raise(Ginseng::GatewayError) {http.get(URL)}
      assert_requested(stub, times: 1)
    end

    # 5xx は既定でも再送する（この振る舞いを壊していないこと）
    def test_retries_server_error_by_default
      stub = stub_request(:get, URL).to_return({status: 500}, {status: 200, body: '{}'})

      assert_equal('{}', HTTP.new.get(URL).body)
      assert_requested(stub, times: 2)
    end

    # 再送しても直らなければ最後は raise する
    def test_gives_up_after_retry_limit
      stub = stub_request(:get, URL).to_return(status: 404)
      http = HTTP.new
      http.retry_not_found = true

      assert_raise(Ginseng::GatewayError) {http.get(URL)}
      assert_requested(stub, times: http.retry_limit)
    end

    # 🔴 取得側が opt-in していること。ここが false に戻ると #38 が再発し、
    # 本番では当日ぶんの投稿が落ちる (pooza/tomato-shrieker#1578)。
    def test_calendar_enables_retry_not_found
      Calendar.all.each do |calendar|
        assert_true(
          calendar.instance_variable_get(:@http).retry_not_found,
          "#{calendar.name} が retry_not_found を有効にしていない",
        )
      end
    end
  end
end
