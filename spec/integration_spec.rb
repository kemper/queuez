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
        chain.add(Queuez::Middleware::JobEnqueue)
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
        chain.add(Queuez::Middleware::JobEnqueue)
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
    before do
      Queuez::Initializer.new.initialize!(
        {
          queues: [
            {name: :something},
            {name: :something_else},
          ]
        }
      )
    end

    describe "when there is work to do" do
      before do
        Queuez::Job.create!(shard: 1, queue: "something", content: "")
        Queuez::Job.create!(shard: 1, queue: "something_else", content: "")
      end

      it "delivers work to the something worker once" do
        expect(something_worker).to receive(:work) do |options|
          expect(options[:job].content).to eq("some other content")
        end
        Queuez.enqueue(queue: "something", shard: "some-shard", content: "some content")
        sleep 10
      end

      it "delivers work to the something else worker once" do
        expect(something_else_worker).to receive(:work) do |options|
          expect(options[:job].content).to eq("some other content")
        end
        Queuez.enqueue(queue: "something_else", shard: "some-shard", content: "some other content")
        sleep 10
      end
    end

    describe "when there is not work to do" do
      it "calls the middleware chain periodically"
    end
  end
end
