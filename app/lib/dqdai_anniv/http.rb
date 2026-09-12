module DqdaiAnniv
  class HTTP < Ginseng::HTTP
    include Package

    # 取得元が間欠的に 404 を返すとき true にする (#38)。
    #
    # ⚠ **既定は false のまま。**ginseng-core の「恒久的な失敗を再送しない」方針
    # (RETRYABLE_STATUSES = [408, 425, 429] と 5xx) は正しく、全体を巻き戻しては
    # いけない。本当に消えた URL まで retry_limit 回叩くことになる。
    attr_accessor :retry_not_found

    private

    # カレンダーの URL は mstdn.delmulin.com から Google Apps Script の /exec へ
    # 302 で飛ぶ。⚠ **その GAS が、生きているのに間欠的に 404 を返す。**404 を
    # 恒久的な失敗として即 raise すると、一過性の揺らぎがそのまま実行の失敗になる。
    #
    # 🔴 **本番 (pooza/tomato-shrieker の CommandSource) では当日ぶんの投稿が
    # 丸ごと落ちる。**bin/anniv.rb は例外で exit 1 するだけで、日付依存の
    # コンテンツなので翌日の実行では取り返せない (2026-09-11 / 09-12 に実際に
    # 2 日連続で失われた = pooza/tomato-shrieker#1578)。
    def retryable?(error)
      return true if retry_not_found && not_found?(error)
      return super
    end

    def not_found?(error)
      return false unless error.is_a?(Ginseng::GatewayError)
      return error.source_status == 404
    end
  end
end
