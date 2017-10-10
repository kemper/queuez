class Queuez::Middleware::ProduceWork
  def call(options)
    job = Queuez::Job.where(queue: options[:queue], completed: false).first
    if job
      Queuez.logger.debug "Found work to do for queue: #{job}"
      options[:shard] = job.shard
      yield options
    else
      Queuez.logger.debug "Did not find work to do for queue: #{options[:queue]}"
    end
  end
end
