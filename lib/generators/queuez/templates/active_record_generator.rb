require "rails/generators/migration"
require "rails/generators/active_record"
require 'rails/generators/base'

module Queuez
  module NextMigrationVersion
    def next_migration_number(dirname)
      next_migration_number = current_migration_number(dirname) + 1
      if ActiveRecord::Base.timestamped_migrations
        [Time.now.utc.strftime("%Y%m%d%H%M%S"), format("%.14d", next_migration_number)].max
      else
        format("%.3d", next_migration_number)
      end
    end
  end

  class CommonGenerator < Rails::Generators::Base
    source_paths << File.join(File.dirname(__FILE__), 'templates')

    def create_executable_file
      template 'script', "bin/queuez"
      chmod "bin/queuez", 0o755
    end
  end

  class ActiveRecordGenerator < ::CommonGenerator
    include Rails::Generators::Migration
    extend NextMigrationVersion

    source_paths << File.join(File.dirname(__FILE__), "templates")

    def create_migration_file
      migration_template "migration.rb", "db/migrate/create_queuez_jobs.rb", migration_version: migration_version
    end

    def self.next_migration_number(dirname)
      ActiveRecord::Generators::Base.next_migration_number dirname
    end

    private

    def migration_version
      if ActiveRecord::VERSION::MAJOR >= 5
        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end
    end
  end
end
