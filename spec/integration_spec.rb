require 'spec_helper'

describe "integration" do
  class JobEnqueueMiddleware
    def call
      puts self.class.name
    end
  end
  class ProduceWorkMiddleware
    def call
      puts self.class.name
    end
  end
  class JobWorkerMiddleware
    def call
      puts self.class.name
    end
  end

  it "can add middleware to the 3 chains" do
    Queuez.configure do |config|
      config.client_middleware do |chain|
        chain.add(JobEnqueueMiddleware)
      end
      config.producer_middleware do |chain|
        chain.add(ProduceWorkMiddleware)
      end
      config.consumer_middleware do |chain|
        chain.add(JobWorkerMiddleware)
      end
    end
  end
end
