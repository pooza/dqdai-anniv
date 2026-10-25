require 'timecop'
require 'webmock'

module DqdaiAnniv
  class TestCase < Ginseng::TestCase
    include Package
    include WebMock::API

    def teardown
      config.reload
      @handler&.clear
      Timecop.return
      WebMock.reset!
    end

    # ⚠ **読めなかったテストファイルを失敗として残す（ginseng-core#696）。**以前は `- case:` の 1 行で
    # 飛ばし、そのファイルのテストが 1 本も走らないまま緑になっていた。上書きしているので、上流の
    # `load` と同じく失敗を集めて `report_load_errors` へ渡す。⚠ 無効なハンドラは失敗にしない。
    def self.load(cases = nil)
      ENV['TEST'] = Package.full_name
      errors = {}
      names(cases).each do |name|
        if name.end_with?('_handler') && Handler.create(name).disable?
          puts "- case: #{name} (disabled)" if Environment.test?
          next
        end
        puts "+ case: #{name}" if Environment.test?
        require File.join(dir, "#{name}.rb")
      rescue => e
        puts "- case: #{name} (#{e.message})" if Environment.test?
        errors[name] = e
      end
      report_load_errors(errors)
    end

    def self.names(cases = nil)
      if cases
        names = cases.split(',')
          .map {|v| [v, "#{v}Test", v.underscore, "#{v.underscore}_test"]}.flatten
          .select {|v| File.exist?(File.join(dir, "#{v}.rb"))}.compact
      else
        names = Dir.glob(File.join(dir, '*.rb')).map {|v| File.basename(v, '.rb')}
      end
      return names.to_set
    end

    def self.dir
      return File.join(Environment.dir, 'test')
    end
  end
end
