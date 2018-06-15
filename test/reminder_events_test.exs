defmodule ReminderEventsTest do
  use ExUnit.Case
  doctest Reminder
  alias Reminder.Events

  describe "filter_events tests" do

    test "event list empty" do
      assert Events.filter_events({~D[2010-09-10], []}) == :no_events
    end

    test "non recurring event in list is preserved if date is today or later" do
      assert Events.filter_events(
               {Date.utc_today(),
                [{"Event1", false, "Is an event"}, {"Event2", true, "Is also an event"}]}
             ) == [{"Event1", false, "Is an event"}, {"Event2", true, "Is also an event"}]
    end

    test ":no_event returned if event list is empty after filtering" do
      assert Events.filter_events(
               {~D[2010-12-12],
                [{"Event1", false, "Is an event"}, {"Event2", false, "Is also an event"}]}
             ) == :no_events
    end

    test "non recurring event in list is removed if date is earlier than today" do
      assert Events.filter_events(
               {~D[2010-01-01],
                [{"Event1", false, "Is an event"}, {"Event2", true, "Is also an event"}]}
             ) == [{"Event2", true, "Is also an event"}]
    end

  end

  test "create_message() produces correct message" do
    event_list = [{"Event1", false, "Is an event"}, {"Event2", true, "Is also an event"}]
    event_message = """
    Events for today (#{Date.utc_today()}):
    
    Event1 - Is an event
    Event2 - Is also an event
    """
    assert Events.create_message(event_list) == event_message
  end
  
  # describe "send_reminders pipeline tests" do
  #   test 

  test "greets the world" do
    assert Reminder.hello() == :world
  end
end
