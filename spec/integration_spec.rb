require 'mysql2'
require 'spec_helper'

describe "integration" do

  class SomethingWorker < Queuez::Worker
    queue "something"

    def work(options)
    end
  end

  class SomethingElseWorker < Queuez::Worker
    queue "something_else"

    def work(options)
    end
  end

  let(:something_worker) { SomethingWorker.new }
  let(:something_else_worker) { SomethingElseWorker.new }

  before do
    Queuez.configure(:something) do |config|
      config.client_middleware do |chain|
        chain.add(Queuez::Middleware::CreateBackgroundJob)
      end
      config.producer_middleware do |chain|
        chain.add(Queuez::Middleware::ProduceWork)
      end
      config.consumer_middleware do |chain|
        chain.add(Queuez::Middleware::JobWorker)
      end
    end
    Queuez.configure(:something_else) do |config|
      config.client_middleware do |chain|
        chain.add(Queuez::Middleware::CreateBackgroundJob)
      end
      config.producer_middleware do |chain|
        chain.add(Queuez::Middleware::ProduceWork)
      end
      config.consumer_middleware do |chain|
        chain.add(Queuez::Middleware::JobWorker)
      end
    end

    allow(SomethingWorker).to receive(:new).and_return(something_worker)
    allow(SomethingElseWorker).to receive(:new).and_return(something_else_worker)

  end

  describe "inline work" do
    it "routes to a something worker" do
      expect(something_worker).to receive(:work) do |options|
        expect(options[:content]).to eq("some content")
      end
      Queuez.enqueue(queue: :something, shard: "some-shard", content: "some content", inline: true)
    end

    it "can do work inline" do
      expect(something_else_worker).to receive(:work) do |options|
        expect(options[:content]).to eq("some other content")
      end
      Queuez.enqueue(queue: :something_else, shard: "some-shard", content: "some other content", inline: true)
    end
  end

  describe "background work" do
    let(:initializer) do
      Queuez::Initializer.new.tap do |i|
        i.initialize!(
          {
            queues: [
              {name: :something},
              {name: :something_else},
            ]
          }
        )
      end
    end

    before do
      Queuez.clear_config!
      initializer.start_all
    end

    after do
      initializer.stop_all
    end

    describe "when there is work to do" do
      it "delivers work to the something worker once" do
        call_count = 0
        expect(something_worker).to receive(:work) do |options|
          call_count += 1
          expect(options[:job].content).to eq("some content")
        end
        Queuez.enqueue(queue: "something", shard: "some-shard", content: "some content")
        sleep 5
        expect(call_count).to eq 1
      end

      it "delivers work to the something else worker once" do
        call_count = 0
        expect(something_else_worker).to receive(:work) do |options|
          call_count += 1
          expect(options[:job].content).to eq("some other content")
        end
        Queuez.enqueue(queue: "something_else", shard: "some-other-shard", content: "some other content")
        sleep 5
        expect(call_count).to eq 1
      end
    end

    describe "when there is not work to do" do
      it "calls the middleware chain periodically"
    end
  end
end
