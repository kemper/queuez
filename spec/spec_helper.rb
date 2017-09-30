$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'queuez'
require 'pry'

db_adapter, gemfile = ENV["ADAPTER"], ENV["BUNDLE_GEMFILE"]
db_adapter, gemfile = ENV["ADAPTER"], ENV["BUNDLE_GEMFILE"]
db_adapter ||= gemfile && gemfile[%r{gemfiles/(.*?)/}] && $1 # rubocop:disable PerlBackrefs
db_adapter ||= "mysql2"

config = YAML.load(File.read("spec/database.yml"))
ActiveRecord::Base.establish_connection config[db_adapter]
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

# Add this directory so the ActiveSupport autoloading works
# ActiveSupport::Dependencies.autoload_paths << File.dirname(__FILE__)
