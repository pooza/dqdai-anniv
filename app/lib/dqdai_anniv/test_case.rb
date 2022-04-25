require 'timecop'

module DqdaiAnniv
  class TestCase < Ginseng::TestCase
    include Package

    def teardown
      config.reload
      @handler&.clear
      Timecop.return
    end

    def self.load(cases = nil)
      ENV['TEST'] = Package.full_name
      names(cases).each do |name|
        raise 'disabled' if name.end_with?('_handler') && Handler.create(name).disable?
        puts "+ case: #{name}" if Environment.test?
        require File.join(dir, "#{name}.rb")
      rescue => e
        puts "- case: #{name} (#{e.message})" if Environment.test?
      end
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
