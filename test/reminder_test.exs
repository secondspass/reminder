defmodule ReminderTest do
  use ExUnit.Case
  doctest Reminder

  test "greets the world" do
    assert Reminder.hello() == :world
  end
end
