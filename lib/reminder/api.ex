defmodule Reminder.API do
  alias Reminder.Server
  alias Reminder.Events

  def send_reminders do
    event_map = %{
      today: Server.get_today() |> Events.filter_events(:today),
      tomorrow: Server.get_tomorrow() |> Events.filter_events(:tomorrow),
      next_week: Server.get_next_week() |> Events.filter_events(:next_week)
    }

    event_map |> Events.create_message() |> Events.send_email()
  end

  def insert_events_from_csv(file_location) do
    File.open(file_location, [:utf8], fn file ->
      # reads and discards the first line as they are headings
      IO.read(file, :line)

      csv_to_tuples(file)
      |> Enum.map(&Server.insert_event/1)
    end)
  end

  @doc """
  Takes a file handle for a csv file and returns a list of tuples,
  each tuple containing the items of each line
  """
  def csv_to_tuples(file) do
    for line <- IO.stream(file, :line), line != :eof do
      line
      |> String.trim()
      |> String.split(",")
      |> List.to_tuple()
      |> format_tuple_items
    end
  end

  defp format_tuple_items({date_string, event_name, recur_string, priority_string, event_desc}) do
    {date_string |> Date.from_iso8601!() |> Date.to_erl(), event_name,
     recur_string |> String.to_atom(), priority_string |> String.to_integer(), event_desc}
  end
end
