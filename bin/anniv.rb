#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.join(File.expand_path('..', __dir__), 'app/lib'))

require 'dqdai_anniv'
module DqdaiAnniv
  messages = {}
  Calendar.all.each do |calendar|
    calendar.messages.each do |k, v|
      messages[k] ||= []
      messages[k].concat(v)
    end
  end
  date = ARGV.shift || Date.today.strftime('%m%d')
  puts messages[date]&.join("\n=====\n")
rescue => e
  warn e.message
  exit 1
end
