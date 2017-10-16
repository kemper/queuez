module Queuez
  class ThreadPool
    attr_reader :pool_size, :task, :stopped, :threads

    def initialize(options)
      @threads = []
      @pool_size = 1
      @task = nil
      @stopped = false
      set_options(options)
    end

    def start
      start_threads
    end

    def pause
      stop_threads
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
      living.size
    end

    def update_options(options)
      set_options(options)
      stop_threads
      wait_for_stop
      perform_maintenance
    end

    def perform_maintenance
      threads.reject! { |t| !t.alive? }
      (@pool_size - threads.size).times do
        threads << start_thread
      end
    end

    protected

    def wait_for_stop
      loop do
        if threads.any? &:alive?
          puts "threads livig"
          sleep (0.1)
        else
          break
        end
      end
    end

    def stop_threads
      @stopped = true
    end

    def set_options(options)
      @pool_size = options[:pool_size] #if options[:pool_size]
      @task = options[:task] #if options[:task]
    end

    def start_threads
      @pool_size.times do
        @threads << start_thread
      end
    end

    def start_thread
      Thread.new do
        loop do
          if stopped
            break
          else
            task.call
          end
        end
      end
    end
  end
end
