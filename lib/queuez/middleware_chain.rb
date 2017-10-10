module Queuez
  class MiddlewareChain
    include Enumerable

    def initialize(middleware = [])
      @middleware = middleware
    end

    def each(&block)
      @middleware.each(&block)
    end

    def <=>(a, b)
      a <=> b
    end

    def add(a)
      @middleware << a
    end

    def delete(a)
      @middleware.delete a
    end

    def clear
      @middleware.clear
    end

    def insert_before(a, b)
      index = @middleware.index(a)
      @middleware.insert(index, b)
    end

    def insert_after(a, b)
      index = @middleware.index(a)
      @middleware.insert(index + 1, b)
    end

    def call(context)
      return if @middleware.empty?

      remaining = @middleware.dup
      current = remaining.shift
      next_function = lambda do |new_context|
        middleware = self.class.new(remaining)
        middleware.call(new_context)
      end
      puts "About to call middleware: #{current} with #{context}" if ENV["DEBUG"] == "true"
      current.new.call(context, &next_function)
    end
  end
end
