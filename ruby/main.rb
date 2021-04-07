require_relative 'worker'

init

loop do
  update_all
  sleep 5.minutes
end