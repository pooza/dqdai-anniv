#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.join(File.expand_path('..', __dir__), 'app/lib'))

require 'dqdai_anniv'
module DqdaiAnniv
  date = ARGV.shift || Date.today.strftime('%m%d')
  entries = {}
  Calendar.all.each do |calendar|
    calendar.messages.each do |k, messages|
      entries[k] ||= []
      entries[k].concat(messages)
    end
  end
  puts entries[date].join("\n=====\n")

rescue => e
  warn e.message
  exit 1
end
