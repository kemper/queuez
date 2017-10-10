module Queuez
  module Middleware
    class JobWorker
      def call(options)
        worker_class = Queuez.config_for(options[:queue]).worker_class
        job = Queuez::Job.where(queue: options[:queue], shard: options[:shard], completed: false).first
        if job
          options[:job] = job
          worker_class.new.work(options)
        end
        job.update!(completed: true, succeeded_at: Queuez::Time.now)
      end
    end
  end
end
