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
  end

  @config = Config.new

  def self.configure
    yield @config
  end
end
