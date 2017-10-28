module Queuez
  class ConsumerPool
    attr_reader :pool_size, :task, :threads, :queue

    def initialize(options)
      @threads = []
      @pool_size = 1
      @task = nil
      set_options(options)
    end

    def start
      start_threads
    end

    def count
      @threads.size
    end

    def living
      @threads.select { |t| t.alive? }
    end

    def dead
      @threads.select { |t| !t.alive? }
    end

    def dead_count
      dead.count
    end

    def living_count
      living.count
    end

    def perform_maintenance
      threads.reject! { |t| !t.alive? }
      if @pool_size > threads.size
        (@pool_size - threads.size).times do
          threads << start_thread
        end
      end
    end

    protected

    def set_options(options)
      @pool_size = options[:pool_size] #if options[:pool_size]
      @task = options[:task] #if options[:task]
      @queue = options[:queue] if options[:queue]
    end

    def start_threads
      @pool_size.times do
        @threads << start_thread
      end
    end

    def start_thread
      Thread.new do
        loop do
          job = queue.pop
          task.call(job)
        end
      end
    end
  end
end
