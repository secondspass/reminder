defmodule ReminderEventsTest do
  use ExUnit.Case
  doctest Reminder
  alias Reminder.Events

  describe "filter_events tests:" do
    setup do
      today = Date.utc_today()
      tomorrow = Date.add(Date.utc_today(), 1)
      next_week = Date.add(Date.utc_today(), 7)
      today_erl = Date.to_erl(today)
      tomorrow_erl = Date.to_erl(tomorrow)
      next_week_erl = Date.to_erl(next_week)

      [
        today_data: [
          # today
          {today_erl,
           [
             {"Event1", false, 1, "Is an event"},
             {"Event2", true, 1, "Is also an event"},
             {"Event3", false, 2, "Is another event"},
             {"Event4", true, 2, "Is yet another event"}
           ]},
          # same day and month as today but past year
          {{2012, today.month, today.day},
           [
             {"Event5", false, 1, "Is an event"},
             {"Event6", true, 1, "Is also an event"},
             {"Event7", false, 2, "Is another event"},
             {"Event8", true, 2, "Is yet another event"}
           ]},
          # same day and month as today but future year
          {{2100, today.month, today.day},
           [
             {"Event9", false, 1, "Is an event"},
             {"Event10", true, 1, "Is also an event"},
             {"Event11", false, 2, "Is another event"},
             {"Event12", true, 2, "Is yet another event"}
           ]}
        ],
        tomorrow_data: [
          # tomorrow
          {tomorrow_erl,
           [
             {"Event1", false, 1, "Is an event"},
             {"Event2", true, 1, "Is also an event"},
             {"Event3", false, 2, "Is another event"},
             {"Event4", true, 2, "Is yet another event"}
           ]},
          # same day and month as tomorrow but past year
          {{2012, tomorrow.month, tomorrow.day},
           [
             {"Event5", false, 1, "Is an event"},
             {"Event6", true, 1, "Is also an event"},
             {"Event7", false, 2, "Is another event"},
             {"Event8", true, 2, "Is yet another event"}
           ]},
          # same day and month as tomorrow but future year
          {{2100, tomorrow.month, tomorrow.day},
           [
             {"Event9", false, 1, "Is an event"},
             {"Event10", true, 1, "Is also an event"},
             {"Event11", false, 2, "Is another event"},
             {"Event12", true, 2, "Is yet another event"}
           ]}
        ],
        next_week_data: [
          # next_week
          {next_week_erl,
           [
             {"Event1", false, 1, "Is an event"},
             {"Event2", true, 1, "Is also an event"},
             {"Event3", false, 2, "Is another event"},
             {"Event4", true, 2, "Is yet another event"}
           ]},
          # same day and month as next_week but past year
          {{2012, next_week.month, next_week.day},
           [
             {"Event5", false, 1, "Is an event"},
             {"Event6", true, 1, "Is also an event"},
             {"Event7", false, 2, "Is another event"},
             {"Event8", true, 2, "Is yet another event"}
           ]},
          # same day and month as next_week but future year
          {{2100, next_week.month, next_week.day},
           [
             {"Event9", false, 1, "Is an event"},
             {"Event10", true, 1, "Is also an event"},
             {"Event11", false, 2, "Is another event"},
             {"Event12", true, 2, "Is yet another event"}
           ]}
        ],
        empty_event_data: [
          {today_erl, []},
          {{2012, next_week.month, next_week.day},
           [
             {"Event5", false, 1, "Is an event"},
             {"Event6", true, 1, "Is also an event"},
             {"Event7", false, 2, "Is another event"}
           ]}
        ]
      ]
    end

    test "today's events are filtered out correctly and final event list is produced", fixture do
      assert MapSet.equal?(
               MapSet.new(Events.filter_events(fixture.today_data)),
               MapSet.new([
                 {"Event1", false, 1, "Is an event"},
                 {"Event2", true, 1, "Is also an event"},
                 {"Event3", false, 2, "Is another event"},
                 {"Event4", true, 2, "Is yet another event"},
                 {"Event6", true, 1, "Is also an event"},
                 {"Event8", true, 2, "Is yet another event"}
                 # future events must not appear
               ])
             )
    end

    test "tomorrow's events are filtered out correctly and final event list is produced",
         fixture do
      assert MapSet.equal?(
               MapSet.new(Events.filter_events(fixture.tomorrow_data)),
               MapSet.new([
                 {"Event1", false, 1, "Is an event"},
                 {"Event2", true, 1, "Is also an event"},
                 {"Event3", false, 2, "Is another event"},
                 {"Event4", true, 2, "Is yet another event"},
                 {"Event6", true, 1, "Is also an event"},
                 {"Event8", true, 2, "Is yet another event"}
                 # future events must not appear
               ])
             )
    end

    test "next week's events are filtered out correctly and final event list is produced",
         fixture do
      assert MapSet.equal?(
               MapSet.new(Events.filter_events(fixture.next_week_data)),
               MapSet.new([
                 {"Event3", false, 2, "Is another event"},
                 {"Event4", true, 2, "Is yet another event"},
                 {"Event8", true, 2, "Is yet another event"}
                 # future events must not appear
               ])
             )
    end

    test "filter_events returns :no_events if final event list is empty", fixture do
      assert Mapset.equal?(
               MapSet.new(Events.filter_events(fixture.empty_event_data)),
               MapSet.new([])
             )
    end
  end

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
        ],
        later_date: Date.add(Date.utc_today(), 4),
        earlier_date: Date.add(Date.utc_today(), -4)
      ]
    end

    test "event list empty", _fixture do
      assert Events.filter_non_recurring_events({~D[2010-09-10], []}) == {~D[2010-09-10], []}
    end

    test "non recurring event in list is preserved if date is today or later", fixture do
      assert Events.filter_non_recurring_events({Date.utc_today(), fixture.test_events}) ==
               {Date.utc_today(), fixture.test_events}

      assert Events.filter_non_recurring_events({fixture.later_date, fixture.test_events}) ==
               {fixture.later_date, fixture.test_events}

      refute Events.filter_non_recurring_events({fixture.earlier_date, fixture.test_events}) ==
               {fixture.earlier_date, fixture.test_events}
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
    # not testing this separately for now. email sending works good enough.
    nil
  end

  # describe "send_reminders pipeline tests" do
  #   test 
end
