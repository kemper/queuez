require "queuez/version"
require 'yaml'
require 'active_record'

require "./lib/queuez/middleware_chain.rb"
require "./lib/queuez/config.rb"
Dir["./lib/queuez/*.rb"].sort.each {|file| require file }
Dir["./lib/queuez/middleware/*.rb"].sort.each {|file| require file }

module Queuez
  @config = Config.new

  def self.configure
    yield @config
  end

  def self.enqueue(options)
    @config.get_client_middleware.call(options)
    if options[:inline]
      @config.get_consumer_middleware.call(options)
    end
  end

  def self.register_queue(name, klazz)
    @config.register_queue(name, klazz)
  end

  def self.worker_for(queue_name)
    @config.worker_for(queue_name)
  end

end
