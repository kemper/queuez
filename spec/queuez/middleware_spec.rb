require 'spec_helper'

describe Queuez::Middleware do
  class Middleware1
    def call(context)
      yield(context)
    end
  end

  class Middleware2
    def call(context)
      yield(context)
    end
  end

  class Middleware3
    def call(context)
      yield(context)
    end
  end

  class NonYieldingMiddleware
    def call(context)
    end
  end

  describe "#add" do
    it 'adds a middleware' do
      subject.add(Middleware1)
      subject.add(Middleware2)
      expect(subject.to_a).to eq [Middleware1, Middleware2]
    end
  end

  describe "#insert_after" do
    it 'inserts after' do
      subject.add(Middleware1)
      subject.add(Middleware3)
      subject.insert_after(Middleware1, Middleware2)
      expect(subject.to_a).to eq [Middleware1, Middleware2, Middleware3]
    end

    it 'inserts after last' do
      subject.add(Middleware1)
      subject.add(Middleware3)
      subject.insert_after(Middleware3, Middleware2)
      expect(subject.to_a).to eq [Middleware1, Middleware3, Middleware2]
    end
  end

  describe "#insert_before" do
    it 'inserts before' do
      subject.add(Middleware1)
      subject.add(Middleware3)
      subject.insert_before(Middleware3, Middleware2)
      expect(subject.to_a).to eq [Middleware1, Middleware2, Middleware3]
    end

    it 'inserts before first' do
      subject.add(Middleware1)
      subject.add(Middleware3)
      subject.insert_before(Middleware1, Middleware2)
      expect(subject.to_a).to eq [Middleware2, Middleware1, Middleware3]
    end
  end

  describe "#delete" do
    it 'removes the middleware' do
      subject.add(Middleware1)
      subject.add(Middleware3)
      subject.delete(Middleware1)
      expect(subject.to_a).to eq [Middleware3]
    end
  end

  describe "#call" do
    let!(:stub1) { Middleware1.new }
    let!(:stub2) { Middleware2.new }
    let!(:stub3) { Middleware3.new }
    let!(:non_yielding_stub) { NonYieldingMiddleware.new }

    it "executes chain" do
      subject.add(Middleware1)
      subject.add(Middleware2)
      subject.add(Middleware3)

      expect(Middleware1).to receive(:new).and_return stub1
      expect(Middleware2).to receive(:new).and_return stub2
      expect(Middleware3).to receive(:new).and_return stub3

      context = {}
      expect(stub1).to receive(:call).with(context).and_call_original
      expect(stub2).to receive(:call).with(context).and_call_original
      expect(stub3).to receive(:call).with(context).and_call_original

      subject.call(context)
    end

    it "stop execution when middleware doesn't yield" do
      subject.add(Middleware1)
      subject.add(NonYieldingMiddleware)
      subject.add(Middleware3)

      expect(Middleware1).to receive(:new).and_return stub1
      expect(NonYieldingMiddleware).to receive(:new).and_return non_yielding_stub

      context = {}
      expect(stub1).to receive(:call).with(context).and_call_original
      expect(non_yielding_stub).to receive(:call).with(context).and_call_original
      expect(stub3).to_not receive(:call)

      subject.call(context)
    end
  end
end
