require 'spec_helper'

describe Queuez::ThreadPool do
  let(:queue) { SizedQueue.new(2) }

  let(:worked) { SizedQueue.new(2) }

  let(:task) do
    Proc.new do
      puts "prepop"
      worked << queue.pop
      puts "postpop"
    end
  end

  let(:options) do
    {
      pool_size: 2,
      task: task
    }
  end

  subject(:thread_pool) do
    Queuez::ThreadPool.new(options)
  end

  it "executes job" do
    thread_pool.start
    queue << 1
    queue << 2
    sleep 1
    expect(worked.size).to eq 2
    expect([worked.pop, worked.pop]).to match_array([1, 2])
  end

  describe "errors" do
    let(:task) do
      Proc.new do
        puts "prepop"
        worked << queue.pop
        raise "BOOM"
      end
    end

    it "creates new threads when old threads die" do
      thread_pool.start
      queue << 1
      queue << 2
      expect(thread_pool.living_count).to eq 0
      expect(thread_pool.dead_count).to eq 2

      thread_pool.perform_maintenance

      expect(thread_pool.living_count).to eq 2
      expect(thread_pool.dead_count).to eq 0
    end

    it "does not create more threads unless the pool_size is greater than existing live threads"
  end

  it "allows threads to be discarded when asked to scale down" do
    thread_pool.start
    thread_pool.update_options({pool_size: 1})
    sleep 1
    expect(thread_pool.count).to eq 1
  end

  it "creates new threads when more are configured" do
    thread_pool.start
    thread_pool.update_options({pool_size: 3})
    sleep 1
    expect(thread_pool.count).to eq 3
  end

  it "stops all threads once work is completed" do
    thread_pool.start
    thread_pool.pause
    queue << 1
    queue << 2
    sleep 1
    expect([queue.pop, queue.pop]).to match_array([1, 2])
    expect(thread_pool.dead_count).to eq 2
  end

end
