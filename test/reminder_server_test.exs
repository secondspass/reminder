defmodule ReminderServerTest do
  use ExUnit.Case
  doctest Reminder
  alias Reminder.Server

  # need to create prod and test ets tables
  # decide on the data structure to hold the today, tomorrow and next week events (just use a list)
end
