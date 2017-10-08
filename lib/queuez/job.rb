module Queuez
  class Job < ActiveRecord::Base
    self.table_name = :queuez_jobs
  end
end
