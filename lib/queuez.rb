require "queuez/version"
require './lib/queuez/middleware'
require 'yaml'
require 'active_record'

module Queuez

  class Config
    def initialize
      @client_middleware = Queuez::Middleware.new
      @producer_middleware = Queuez::Middleware.new
      @consumer_middleware = Queuez::Middleware.new
      @queues = {}
    end

    def client_middleware
      yield @client_middleware
    end

    def producer_middleware
      yield @producer_middleware
    end

    def consumer_middleware
      yield @consumer_middleware
    end

    def register_queue(name, klazz)
      @queues[name.to_s] = klazz
    end

    def worker_for(queue_name)
      @queues[queue_name.to_s]
    end

    def get_client_middleware
      @client_middleware
    end

    def get_producer_middleware
      @producer_middleware
    end

    def get_consumer_middleware
      @consumer_middleware
    end
  end

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
