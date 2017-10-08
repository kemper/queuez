$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'queuez'
require 'pry'
require 'database_cleaner'

db_adapter, gemfile = ENV["ADAPTER"], ENV["BUNDLE_GEMFILE"]
db_adapter, gemfile = ENV["ADAPTER"], ENV["BUNDLE_GEMFILE"]
db_adapter ||= gemfile && gemfile[%r{gemfiles/(.*?)/}] && $1 # rubocop:disable PerlBackrefs
db_adapter ||= "mysql2"

config = YAML.load(File.read("spec/database.yml"))
db_config = config[db_adapter].dup
database = db_config.delete("database")

ActiveRecord::Base.establish_connection db_config
begin
  ActiveRecord::Base.connection.create_database(database)
rescue => ActiveRecord::StatementInvalid
  puts "Database exists"
end

db_config = config[db_adapter].dup
ActiveRecord::Base.establish_connection db_config
ActiveRecord::Migration.verbose = false

migration_template = File.open("lib/generators/queuez/templates/migration.rb")

# need to eval the template with the migration_version intact
migration_context = Class.new do
  def get_binding
    binding
  end

  private

  def migration_version
    if ActiveRecord::VERSION::MAJOR >= 5
      "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
    end
  end
end

migration_ruby = ERB.new(migration_template.read).result(migration_context.new.get_binding)
eval(migration_ruby)

ActiveRecord::Schema.define do
  CreateQueuezJobs.up
end

# Add this directory so the ActiveSupport autoloading works
# ActiveSupport::Dependencies.autoload_paths << File.dirname(__FILE__)

RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

end
