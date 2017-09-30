class CreateQueuezJobs < ActiveRecord::Migration<%= migration_version %>
  def self.up
    create_table :queuez_jobs, force: true do |table|
      table.integer :priority, default: 0, null: false
      table.integer :attempts, default: 0, null: false
      table.datetime :run_at
      table.datetime :started_at
      table.datetime :failed_at
      table.datetime :succeeded_at
      table.boolean :completed, default: false
      table.string :queue
      table.string :shard
      table.text :last_error

      table.timestamps null: true
    end
    add_index :queuez_jobs, [:completed, :priority, :run_at], name: "queuez_jobs_priority"
  end
  def self.down
    drop_table :queuez_jobs
  end
end
