defmodule App.Actions do
  @moduledoc false

  require Logger
  use App.Commander

  @form_url "https://docs.google.com/forms/d/e/1FAIpQLScpSOicLFqYdzJO3UeHtnFJy8RWdDM0YvHVev_tNZdXqIuhNQ/viewform"

  @default_markup  %Model.InlineKeyboardMarkup{
    inline_keyboard: [
      [
        %{
          callback_data: "/fill_form",
          text: "Сообщить новую информацию",
          url: @form_url
          #              url: "https://docs.google.com/forms/d/e/1FAIpQLScpSOicLFqYdzJO3UeHtnFJy8RWdDM0YvHVev_tNZdXqIuhNQ/viewform?usp=pp_url&entry.22906134=name&entry.1856883854=year&entry.1650477813=date"
        }
      ],
      [
        %{
          callback_data: "/search",
          text: "Обновить поиск"
        }
      ],
      [
        %{
          callback_data: "/speed_up",
          text: "Ускорить процесс"
        }
      ],
      [
        %{
          callback_data: "/restart",
          text: "Ввести другую фамилию"
        }
      ]
    ]
  }


  def search(id, q) do
    query = q
            |> String.split(",")
            |> List.first
            |> String.split(" ")
            |> List.first
            |> String.trim
            |> String.capitalize

    State.update_name(id, query)

    url = "http://spiski.live/api?q=#{query}"

    results = case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} -> Poison.decode!(body)
      {:ok, %{status_code: 404}} -> Logger.error("404 for #{url}"); %{"#{query}" => []}
      {:error, %{reason: reason}} -> Logger.error("Error for #{url}: #{reason}"); %{"#{query}" => []}
      _ -> Logger.error("Other error for #{url}"); %{"#{query}" => []}
    end

    new_state = State.update_results(id, results[query])

    Logger.warn "New state:"
    new_state
    |> Logger.warn

    State.set(id, new_state)
    new_state
    |> IO.inspect

    markup(id, query, results[query])
  end

  def wanna_add_new_fields() do
    {"wanna_add_new_fields", []}
  end

  def wanna_add_person() do
    {"wanna_add_person", []}
  end

  def speed_up do
    {
      """
      Как ускорить процесс:

      1. Обзвоните РУВД <a href="http://0908help.tilda.ws/ruvd" target="_blank">по телефонам</a>. Некоторую информацию сообщают только родным. Там будет постоянно занято, но у вас всё получится

      2. Просто звоните 102, если прошло больше суток

      3. Фотографии списков <a href="https://t.me/spiski_okrestina" target="_blank">на канале </a> появляются на несколько часов раньше, чем попадают к боту или на <a href="http://spiski.live" target="_blank">сайт</a>

      4. Если человек до суда был в ИВС или ЦИП, то решение суда можно узнать лично <a href="http://0908help.tilda.ws/sudy" target="_blank">в канцелярии</a> в тот же день. Район суда совпадает с районом РУВД, куда отвезли задержанного. Из Октябрьского РУВД будут судить в суде Октябрьского района

      Решения судов в Жодино появляются <a href="https://t.me/spiski_okrestina" target="_blank">на канале</a>, в базе бота и на <a href="http://spiski.live" target="_blank">сайте</a> на следующий день (иногда через день) после вынесения решения

      5. Узнать, где человек будет сидеть сутки, можно на следующий день (иногда через день) после решения суда у бота, на <a href="http://spiski.live" target="_blank">сайте</a> или <a href="https://t.me/spiski_okrestina" target="_blank">на канале</a>

      6. Если вы узнали что-то самостоятельно, сообщите об этом волонтёрам через <a href="#{
        @form_url
      }" target="_blank">форму</a>
      """,
      parse_mode: 'HTML',
      disable_web_page_preview: true,
      reply_markup: @default_markup
    }
  end

  defp markup(id, query, []) do
    State.update_stage(id, "not_found")
    {
      "На текущий момент информации о задержании человека по фамилии <b>\"#{
        query
      }\"</b> нет. Если вы уверены, что это не так, напишите нам об этом",
      parse_mode: 'HTML',
      reply_markup: %Model.InlineKeyboardMarkup{
        inline_keyboard: [
          [
            %{
              callback_data: "/fill_form",
              text: "Сообщить о задержании",
              url: @form_url
            }
          ],
          [
            %{
              callback_data: "/search",
              text: "Обновить поиск"
            }
          ],
          [
            %{
              callback_data: "/restart",
              text: "Ввести другую фамилию"
            }
          ]
        ]
      }
    }


  end

  defp markup(id, query, results) do
    State.update_stage(id, "found")
    {
      make_pretty(query, results),
      parse_mode: 'HTML',
      reply_markup: @default_markup
    }

  end

  defp make_pretty(query, results) do

    m = Enum.reduce results, "#{query}:\n\n", fn person, message ->
      message = message <> person["ФИО"] <> "\n"

      message = if person["Дата задержания"] != "" do
        message <> "Задержан: <b>#{person["Дата задержания"]}</b>\n\n"
      else
        message
      end

      message = if person["Год"] != "" do
        message <> "Год или дата рождения: #{person["Год"]}\n"
      else
        message <> "Год или дата рождения: неизвестно\n"
      end

      message = if person["Сводка"] != "" do
        message <> "Что известно: #{person["Сводка"]}\n"
      else
        message <> "Что известно: поступила информация о задержании, ждём дополнительной информации. Как только что-то будет известно, информация отобразится здесь или на сайте.\n"
      end

      message = if person["Суд, судья, приговор"] != "" or person["Сутки"] != "" do
        message <> "Суд, судья, приговор: #{person["Суд, судья, приговор"]} #{person["Сутки"]} #{person["Штраф"]}\n"
      else
        message
      end

      message = if person["Отпустили"] != "" do
        message <> "Дополнительная информация: #{person["Отпустили"]}\n"
      else
        message
      end


      message = if person["Дата выхода"] != "" do
        message <> "Дата выхода: #{person["Дата выхода"]} #{person["Время выхода"]}\n"
      else
        message
      end

      message = message <> "__________________________\n\n"
      message
    end

    m
    |> Logger.warn
    m
  end
end
