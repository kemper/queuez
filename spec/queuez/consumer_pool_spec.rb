require 'spec_helper'

describe Queuez::ConsumerPool do
  let!(:queue) { SizedQueue.new(2) }

  let!(:worked) { SizedQueue.new(20) }

  let(:task) do
    Proc.new do |arg|
      worked << arg
    end
  end

  let(:options) do
    {
      pool_size: 2,
      task: task,
      queue: queue
    }
  end

  subject(:consumer_pool) do
    Queuez::ConsumerPool.new(options)
  end

  it "executes job" do
    consumer_pool.start
    sleep 1
    queue << 1
    queue << 2
    sleep 1
    expect(worked.size).to eq 2
    expect([worked.pop, worked.pop]).to match_array([1, 2])
  end

  describe "errors" do
    let(:task) do
      Proc.new do |job|
        raise "BOOM"
      end
    end

    it "creates new threads when old threads die" do
      consumer_pool.start
      queue << 1
      queue << 2
      sleep 1
      expect(consumer_pool.living_count).to eq 0
      expect(consumer_pool.dead_count).to eq 2

      consumer_pool.perform_maintenance

      expect(consumer_pool.living_count).to eq 2
      expect(consumer_pool.dead_count).to eq 0
    end

    it "does not create more threads when nothing to do" do
      consumer_pool.start
      sleep 1
      expect(consumer_pool.living_count).to eq 2
      threads = consumer_pool.threads
      consumer_pool.perform_maintenance
      expect(consumer_pool.threads).to eq threads
    end
  end

end
