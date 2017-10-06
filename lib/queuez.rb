require "queuez/version"
require 'yaml'
require 'active_record'

require "./lib/queuez/middleware_chain.rb"
require "./lib/queuez/config.rb"
Dir["./lib/queuez/*.rb"].sort.each {|file| require file }
Dir["./lib/queuez/middleware/*.rb"].sort.each {|file| require file }

module Queuez
  @configs = {}

  def self.configure(queue_name)
    yield config_for(queue_name)
  end

  def self.config_for(queue_name)
    @configs[queue_name.to_sym] ||= Config.new
  end

  def self.enqueue(options)
    self.configure(options[:queue]) do |config|
      config.get_client_middleware.call(options)
      if options[:inline]
        config.get_consumer_middleware.call(options)
      end
    end
  end

  def self.register_queue(name, klazz)
    self.configure(name) do |config|
      config.worker_class = klazz
    end
  end

  def self.worker_for(name)
    self.configure(name) do |config|
      config.worker_for(name)
    end
  end

end
