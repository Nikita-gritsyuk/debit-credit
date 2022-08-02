module CapybaraHelper
  def with_retries(max_tries: 100, sleep_time: 0.01, &block)
    tries = 0
    begin
      block.call
    rescue StandardError => e
      raise e if (tries += 1) > max_tries

      sleep sleep_time
      retry
    end
  end
end
