require "minitest/autorun"
require 'mysql2'

class TestDB < Minitest::Test
  def setup
    @client = Mysql2::Client.new(host: ENV['MYSQL_HOST'], username: ENV['MYSQL_ROOT_USERNAME'], password: ENV['MYSQL_ROOT_PASSWORD'])
    @client.query("USE #{ENV['MYSQL_DATABASE']};")
  end

  def test_count
    tries = 0

    begin
      result = @client.query("SELECT COUNT(*) FROM records;")
      assert(result.first["COUNT(*)"] > 0)
    rescue Minitest::Assertion => e
      sleep 5
      if tries < 3
        tries += 1
        retry
      else
        raise e
      end
    end
  end
end