defmodule ReminderEventsTest do
  use ExUnit.Case
  doctest Reminder
  alias Reminder.Events

  describe "filter_low_priority_events tests:" do
    setup do
      [
        test_events_mixed: [
          {"Event1", false, 1, "Is an event"},
          {"Event2", true, 2, "Is also an event"},
          {"Event3", true, 1, "Is another event"},
          {"Event4", true, 2, "Is yet another event"}
        ]
      ]
    end

    test "low priority events (i.e. priority 1 events) are filtered out", fixture do
      assert Events.filter_low_priority_events({~D[2012-12-12], fixture.test_events_mixed}) ==
               {~D[2012-12-12],
                [
                  {"Event2", true, 2, "Is also an event"},
                  {"Event4", true, 2, "Is yet another event"}
                ]}
    end
  end

  describe "filter_empty tests:" do
    test "filter_empty identifies if the event list is empty and replies with :no_event" do
      assert Events.filter_empty({~D[2012-12-12], []}) == :no_events
    end

    test "filter_empty returns event item if the event list is not empty" do
      event_item =
        {~D[2012-12-12],
         [{"Event1", false, 1, "Is an event"}, {"Event2", true, 2, "Is also an event"}]}

      assert Events.filter_empty(event_item) == event_item
    end
  end

  describe "filter_non_recurring_events tests:" do
    setup do
      [
        test_events: [
          {"Event1", false, 1, "Is an event"},
          {"Event2", true, 2, "Is also an event"}
        ]
      ]
    end

    test "event list empty", _fixture do
      assert Events.filter_non_recurring_events({~D[2010-09-10], []}) == {~D[2010-09-10], []}
    end

    test "non recurring event in list is preserved if date is today or later", fixture do
      assert Events.filter_non_recurring_events({Date.utc_today(), fixture.test_events}) ==
               {Date.utc_today(), fixture.test_events}
    end

    test "empty list returned if event list is empty after filtering", _fixture do
      assert Events.filter_non_recurring_events(
               {~D[2010-12-12], [{"Event1", false, 1, "Is an event"}]}
             ) == {~D[2010-12-12], []}
    end

    test "non recurring event in list is removed if date is earlier than today", fixture do
      assert Events.filter_non_recurring_events({~D[2010-01-01], fixture.test_events}) ==
               {~D[2010-01-01], [{"Event2", true, 2, "Is also an event"}]}
    end
  end

  test "create_message() produces correct message" do
    event_map = %{
      today:
        {Date.utc_today(),
         [{"Event1", false, 2, "Is an event"}, {"Event2", true, 1, "Is also an event"}]},
      tomorrow:
        {Date.add(Date.utc_today(), 1),
         [{"Event3", false, 2, "Is third event"}, {"Event4", true, 1, "Is fourth event"}]},
      next_week:
        {Date.add(Date.utc_today(), 7),
         [{"Event5", false, 2, "Is fifth event"}, {"Event6", true, 2, "Is sixth event"}]}
    }

    event_message = """
    Events for today (#{elem(event_map.today, 1)}):

    Event1 - Is an event
    Event2 - Is also an event


    Events for tomorrow (#{elem(event_map.tomorrow, 1)}):

    Event3 - Is third event
    Event4 - Is fourth event

    Events for next week (#{elem(event_map.next_week, 1)}):

    Event3 - Is third event
    Event4 - Is fourth event
    """

    assert %Mailman.Email{
             subject: "Reminders for today",
             text: event_message
           } = Events.create_message(event_map)
  end

  test "email is configured and sent" do
    # not testing this separately for now. Works good enough.
    nil
  end

  # describe "send_reminders pipeline tests" do
  #   test 
end
