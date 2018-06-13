defmodule ReminderEventsTest do
  use ExUnit.Case
  doctest Reminder
  alias Reminder.Events

  describe "event list filtering checks" do

    test "event list empty" do
      assert Events.filter_events({~D[2010-09-10], []}) == :no_events
    end

    test "non recurring event in list is preserved if date is today or later" do
      assert Events.filter_events(
               {Date.utc_today(),
                [{"Event1", false, "Is an event"}, {"Event2", true, "Is also an event"}]}
             ) == [{"Event1", false, "Is an event"}, {"Event2", true, "Is also an event"}]
    end

    test "non recurring event in list is removed if date is earlier than today" do
      assert Events.filter_events(
               {~D[2010-01-01],
                [{"Event1", false, "Is an event"}, {"Event2", true, "Is also an event"}]}
             ) == [{"Event2", true, "Is also an event"}]
    end
  end

  test "greets the world" do
    assert Reminder.hello() == :world
  end
end
