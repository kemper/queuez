require 'spec_helper'

describe "integration" do
  class JobEnqueueMiddleware
    def call(options)
      attributes = options.slice(:content, :queue, :shard)
      QueuezJob.create!(attributes)
    end
  end

  class ProduceWorkMiddleware
    def call
      puts self.class.name
    end
  end

  class JobWorkerMiddleware
    def call(options)
      worker_class = Queuez.worker_for(options[:queue])
      job = QueuezJob.where(shard: options[:shard]).first
      options[:job] = job
      worker_class.new.work(options)
    end
  end

  class QueuezJob < ActiveRecord::Base
  end

  class QueuezWorker
    def self.queue(name)
      Queuez.register_queue(name, self)
    end
  end

  class SomethingWorker < QueuezWorker
    queue "something"

    def work(options)
    end
  end

  let(:something_worker) { SomethingWorker.new }

  before do
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

    allow(SomethingWorker).to receive(:new).and_return(something_worker)
  end

  it "can do work inline" do
    expect(something_worker).to receive(:work) do |options|
      expect(options[:content]).to eq("some content")
    end
    Queuez.enqueue(queue: "something", shard: "some-shard", content: "some content", inline: true)
  end
end
