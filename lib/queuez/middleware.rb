class Queuez::Middleware
  include Enumerable

  def initialize
    @middleware = []
  end

  def each(&block)
    @middleware.each &block
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

  def insert_before(a, b)
    index = @middleware.index(a)
    @middleware.insert(index, b)
  end

  def insert_after(a, b)
    index = @middleware.index(a)
    @middleware.insert(index + 1, b)
  end
end
