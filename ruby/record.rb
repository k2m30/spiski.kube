require 'active_record'
require 'mysql2'

ActiveRecord::Base.establish_connection(
  adapter: 'mysql2',
  host: 'db',
  port: 3306,
  username: 'root',
  pool: 5,
  database: ENV['MYSQL_DATABASE'],
  password: ENV['MYSQL_ROOT_PASSWORD'],
  encoding: 'utf8mb4',
  collation: 'utf8mb4_unicode_ci',
  # init_command: "CREATE DATABASE IF NOT EXISTS #{ENV['MYSQL_DATABASE']};"
)

# Set up database tables and columns
ActiveRecord::Schema.define do
  create_table :records, if_not_exists: true, force: false do |t|
    t.integer :sheet_id
    t.integer :record_id
    t.string :last_name
    t.date :date
    t.text :full_info
    t.index ["sheet_id"]
    t.index ["last_name"]
  end
end

# Set up model class
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class Record < ApplicationRecord
end

p Record.count