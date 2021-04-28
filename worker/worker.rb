require 'google/apis/sheets_v4'
require 'json'
require_relative 'record'

SPREADSHEET_ID = ENV['SPREADSHEET_ID']
SHEETS =
  {
    august: { name: "Август для публикации" },
    august_begin: { name: "09.08-23.08 (Весна) для публикации" },
    august_end: { name: "25.08-05.09 для публикации" },
    september: { name: "08.09-26.09 для публикации" },
    october: { name: "Сентябрь-Октябрь для публикации" },
    november: { name: "Ноябрь-Декабрь для публикации" },
    january: { name: "Январь-Февраль для публикации" },
    march: { name: "Март-Апрель для публикации" },
    may: { name: "Май-Июнь для публикации" },
    today: { name: "Сегодня для публикации" },
    digital: { name: "Оцифровка для публикации" }
  }
SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS

def init
  authorization = Google::Auth.get_application_default(SCOPE)
  @service = Google::Apis::SheetsV4::SheetsService.new
  @service.authorization = authorization
  @logger = Logger.new('logs/error.log')
end

def update_sheet(service, spreadsheet_id, sheet_name, sheet_id)

  range = "#{sheet_name}!A1:V"

  response = service.get_spreadsheet_values(spreadsheet_id, range)

  ActiveRecord::Base.transaction do
    headers = response.values.first
    response.values[1..].each do |row|
      record_id = row[0].to_i rescue next
      if record_id > 0
        begin
          date = Date.parse(row[19]) rescue nil
          date = nil if !date.nil? and date.year < 2020
          full_info = JSON[Hash[headers[1..].zip(row[1..])]]
          Record.find_or_create_by(record_id: record_id, sheet_id: sheet_id).update!(last_name: row[15], date: date, full_info: full_info)
        rescue => e
          p row
          p e.message
        end
      end
    end

  end
end

def update_all
  SHEETS.keys.each { |key| p key; update_sheet @service, SPREADSHEET_ID, SHEETS[key][:name], SHEETS.keys.index(key) }
  p Record.all.first
  p Record.all.last
  p Record.count
end


