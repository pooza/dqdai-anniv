require 'bundler/setup'
require 'dqdai_anniv/refines'

module DqdaiAnniv
  using Refines

  # 発売日・誕生日はいずれも日本の日付なので、実行環境の TZ に依存させない
  TIMEZONE = '+09:00'.freeze

  def self.dir
    return File.expand_path('../..', __dir__)
  end

  def self.now
    return Time.now.getlocal(TIMEZONE)
  end

  def self.today
    return now.to_date
  end

  def self.loader
    config = YAML.load_file(File.join(dir, 'config/autoload.yaml'))
    loader = Zeitwerk::Loader.new
    loader.inflector.inflect(config['inflections'])
    loader.push_dir(File.join(dir, 'app/lib'))
    loader.collapse('app/lib/dqdai_anniv/*')
    return loader
  end

  def self.setup_debug
    Ricecream.disable
    return unless Environment.development?
    Ricecream.enable
    Ricecream.include_context = true
    Ricecream.colorize = true
    Ricecream.prefix = "#{Package.name} | "
    Ricecream.define_singleton_method(:arg_to_s, proc {|v| PP.pp(v)})
  end

  def self.load_tasks
    finder = Ginseng::FileFinder.new
    finder.dir = File.join(dir, 'app/task')
    finder.patterns.push('*.rb')
    finder.patterns.push('*.rake')
    finder.exec.each {|f| require f}
  end

  Dir.chdir(dir)
  ENV['BUNDLE_GEMFILE'] = File.join(dir, 'Gemfile')
  Bundler.require
  loader.setup
  setup_debug
end
