module Queuez
  class Worker
    def self.queue(name)
      Queuez.register_queue(name, self)
    end
  end
end
