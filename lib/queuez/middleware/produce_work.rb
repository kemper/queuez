class Queuez::Middleware::ProduceWork
  def call(options)
    puts "producer called"
    job = Queuez::Job.where(queue: options[:queue]).first
    if job
      puts 'FOUND JOB'
      options[:shard] = job.shard
      puts job
      puts job.shard
      yield options
    end
  end
end
