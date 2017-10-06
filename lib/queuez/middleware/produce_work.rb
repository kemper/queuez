class Queuez::Middleware::ProduceWork
  def call(options)
    job = Queuez::QueuezJob.where(shard: options[:shard]).first
    options[:job] = job
    yield options
  end
end
