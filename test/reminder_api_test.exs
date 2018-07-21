defmodule ReminderAPITest do
  use ExUnit.Case
  doctest Reminder
  alias Reminder.API
  alias Reminder.Server
  @test_csv "./priv/exampleevents.csv"

  test "convert csv to list of tuples" do
    file_handle = elem(File.open(@test_csv, [:utf8]), 1)
    IO.read(file_handle, :line)

    assert API.csv_to_tuples(file_handle) == [
             {{1879, 03, 14}, "Albert Einstein", true, 1, "Birthday"},
             {{1955, 07, 12}, "Bieber Man", false, 1, "Birthday"},
             {{1969, 11, 23}, "Tortilla and Salsa", true, 2, "Wedding Anniversary"}
           ]
  end

  test "insert events from csv into db" do
    _rem_serv = elem(Server.start_link(), 1)

    assert API.insert_events_from_csv(@test_csv) == {:ok, [:inserted, :inserted, :inserted]}

    assert API.insert_events_from_csv(@test_csv) ==
             {:ok, [:event_already_present, :event_already_present, :event_already_present]}
  end
end
