require 'spec_helper'

describe Queuez::Middleware do
  class Middleware1
    def call(context)
    end
  end

  class Middleware2
    def call(context)
    end
  end

  class Middleware3
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
    it "executes chain" do
    end
  end
end
