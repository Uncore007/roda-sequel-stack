# Migrate

migrate = lambda do |env, version|
  sh({'RACK_ENV' => env}, FileUtils::RUBY, "-r", "./db", "-r", "logger", "-e", <<~RUBY)
    Sequel.extension :migration
    DB.loggers << Logger.new($stdout) if DB.loggers.empty?
    Sequel::Migrator.apply(DB, 'migrate', #{version.inspect})
  RUBY
end

desc "Migrate test database to latest version"
task :test_up do
  migrate.call('test', nil)
end

desc "Migrate test database all the way down"
task :test_down do
  migrate.call('test', 0)
end

desc "Migrate test database all the way down and then back up"
task :test_bounce do
  migrate.call('test', 0)
  migrate.call('test', nil)
end

desc "Migrate development database to latest version"
task :dev_up do
  migrate.call('development', nil)
end

desc "Migrate development database to all the way down"
task :dev_down do
  migrate.call('development', 0)
end

desc "Migrate development database all the way down and then back up"
task :dev_bounce do
  migrate.call('development', 0)
  migrate.call('development', nil)
end

desc "Migrate production database to latest version"
task :prod_up do
  migrate.call('production', nil)
end

# Shell

irb = proc do |env|
  trap('INT', "IGNORE")
  dir, base = File.split(FileUtils::RUBY)
  cmd = if base.sub!(/\Aruby/, 'irb')
    [File.join(dir, base)]
  else
    [FileUtils::RUBY, "-S", "irb"]
  end
  cmd.unshift({"RACK_ENV" => env})
  cmd << "-r" << "./models"
  sh(*cmd)
end

desc "Open irb shell in test mode"
task :test_irb do 
  irb.call('test')
end

desc "Open irb shell in development mode"
task :dev_irb do 
  irb.call('development')
end

desc "Open irb shell in production mode"
task :prod_irb do 
  irb.call('production')
end

# Specs

spec = proc do |type|
  desc "Run #{type} specs"
  task :"#{type}_spec" do
    sh "#{FileUtils::RUBY} -w #{'-W:strict_unused_block' if RUBY_VERSION >= '3.4'} spec/#{type}.rb"
  end

  desc "Run #{type} specs with coverage"
  task :"#{type}_spec_cov" do
    sh({"COVERAGE" => type, "RODA_RENDER_COMPILED_METHOD_SUPPORT" => "no"}, FileUtils::RUBY, "spec/#{type}.rb")
  end
end
spec.call('model')
spec.call('web')

desc "Run all specs"
task default: [:model_spec, :web_spec]

desc "Run all specs with coverage"
task :spec_cov do
  FileUtils.rm_r('coverage') if File.directory?('coverage')
  Dir.mkdir('coverage')
  Rake::Task['_spec_cov'].invoke
end
task _spec_cov: [:model_spec_cov, :web_spec_cov]

# Other

desc "Annotate Sequel models"
task "annotate" do
  sh({'RACK_ENV' => "test"}, FileUtils::RUBY, "-r", "./models", "-r", "sequel/annotate", "-e", <<~RUBY)
    DB.loggers.clear
    Sequel::Annotate.annotate(Dir['models/**/*.rb'])
  RUBY
end
