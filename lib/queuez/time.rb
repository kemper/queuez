module Queuez
  class Time
    # TODO: look at delayed job again. It checks for zone config. Appears smart.
    def self.now
      ::Time.now
    end
  end
end
