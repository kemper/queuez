module Queuez
  module Middleware
    class CreateBackgroundJob
      def call(options)
        attributes = options.slice(:content, :queue, :shard)
        Queuez::Job.create!(attributes)
      end
    end
  end
end
