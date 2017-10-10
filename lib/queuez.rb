require "queuez/version"
require 'yaml'
require 'active_record'

require "./lib/queuez/middleware_chain.rb"
require "./lib/queuez/config.rb"
Dir["./lib/queuez/*.rb"].sort.each {|file| require file }
Dir["./lib/queuez/middleware/*.rb"].sort.each {|file| require file }

module Queuez
  #TODO: remove storing configs here. I'd rather just have the initializer directly
  # Or maybe that won't work given that I need classes to load to register themselves as workers
  @configs = {}
  @logger = Logger.new($stdout)

  def self.logger
    @logger
  end

  def self.logger=(l)
    @logger = l
  end

  def self.configure(queue_name)
    yield config_for(queue_name)
  end

  def self.config_for(queue_name)
    @configs[queue_name.to_sym] ||= Config.new
    @configs[queue_name.to_sym].queue = queue_name.to_sym
    @configs[queue_name.to_sym]
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

  def self.clear_config!
    @configs.each do |config|
      config.second.get_consumer_middleware.clear
      config.second.get_producer_middleware.clear
      config.second.get_client_middleware.clear
    end
  end

end
