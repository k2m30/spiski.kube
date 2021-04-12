require_relative 'worker'

init

loop do
  update_all
  sleep 5.minutes
rescue => e
  @logger.error e.message
  @logger.error e.backtrace.join["\n"]
  sleep 5.minutes
end