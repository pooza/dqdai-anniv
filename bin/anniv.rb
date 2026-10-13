#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.join(File.expand_path('..', __dir__), 'app/lib'))

require 'dqdai_anniv'
module DqdaiAnniv
  # `--ics <カレンダー名>` は、そのカレンダーの記念日を iCalendar で出す (#47)。
  # ⚠ 引数なし・日付指定（`0927` など）の文章モードは残す。置き換えが済むまで本番が使う。
  if ARGV.first == '--ics'
    names = Config.instance['/calendar'].map {|v| v['name']}
    name = ARGV[1]
    raise "calendar name required (#{names.join(' / ')})" unless names.member?(name)
    puts Calendar.create(name).ical.to_ical
  else
    messages = {}
    Calendar.all.each do |calendar|
      calendar.messages.each do |k, v|
        messages[k] ||= []
        messages[k].concat(v)
      end
    end
    date = ARGV.shift || Date.today.strftime('%m%d')
    puts messages[date]&.join("\n=====\n")
  end
rescue => e
  warn e.message
  exit 1
end
