defmodule ReminderServerTest do
  use ExUnit.Case
  doctest Reminder
  alias Reminder.Server

  describe "Get events from test db:" do
    setup do
      fixture = [
        rem_serv: elem(Server.start_link(), 1)
      ]

      fixture
    end

    test "Insert events and dets sync", fixture do
      event1 = %{
        date: Date.to_erl(Date.utc_today()),
        name: "today event #{Date.utc_today()} #{:rand.normal()}",
        recur: true,
        priority: 1,
        desc: "description #{Date.utc_today()} #{:rand.normal()}"
      }

      # same day, different event
      event2 = %{
        date: Date.to_erl(Date.utc_today()),
        name: "today event #{Date.utc_today()} #{:rand.normal()}",
        recur: true,
        priority: 1,
        desc: "description #{Date.utc_today()} #{:rand.normal()}"
      }

      # insert some event for today (we have not persisted the db yet)
      assert Server.insert_event({
               event1.date,
               event1.name,
               event1.recur,
               event1.priority,
               event1.desc
             }) == :inserted

      assert Server.insert_event({
               event2.date,
               event2.name,
               event2.recur,
               event2.priority,
               event2.desc
             }) == :inserted

      # check if the event above has been inserted
      assert Server.insert_event({
               event1.date,
               event1.name,
               event1.recur,
               event1.priority,
               event1.desc
             }) == :event_already_present

      # sync ets to dets on file
      Server.sync_to_dets()

      # since sync_to_dets is a cast (async operation), we need to force sync by calling
      # :sys.get_state in order to properly open and check the dets to
      # see if the values from the ets were inserted
      # get_state returns the genserver state i.e. the ets table handle
      test_ets = :sys.get_state(fixture.rem_serv)

      # need to use the already opened dets from the genserver to check the values, hence :reminders_dets
      assert :dets.lookup(:reminders_dets, event1.date) == :ets.lookup(test_ets, event2.date)
    end

    test "get_today", fixture do
      # remember, we are only testing the data retrieval. Filtering according to recurrence
      # and priority is of no concern in the retrieval operations
      today = Date.utc_today()

      event = %{
        date: Date.to_erl(today),
        name: "today event #{today} #{:rand.normal()}",
        recur: true,
        priority: 1,
        desc: "description #{today} #{:rand.normal()}"
      }

      Server.insert_event({event.date, event.name, event.recur, event.priority, event.desc})
      test_ets = :sys.get_state(fixture.rem_serv)

      assert :ets.match_object(test_ets, {{:"$1", today.month, today.day}, :"$2"}) ==
               Server.get_today()
    end

    test "get_tomorrow", fixture do
      tomorrow = Date.add(Date.utc_today(), 1)

      event = %{
        date: Date.to_erl(tomorrow),
        name: "tomorrow event #{tomorrow} #{:rand.normal()}",
        recur: true,
        priority: 1,
        desc: "description #{tomorrow} #{:rand.normal()}"
      }

      Server.insert_event({event.date, event.name, event.recur, event.priority, event.desc})
      test_ets = :sys.get_state(fixture.rem_serv)

      assert :ets.match_object(test_ets, {{:"$1", tomorrow.month, tomorrow.day}, :"$2"}) ==
               Server.get_tomorrow()
    end

    test "get_next_week", fixture do
      next_week = Date.add(Date.utc_today(), 7)

      event = %{
        date: Date.to_erl(next_week),
        name: "next_week event #{next_week} #{:rand.normal()}",
        recur: true,
        priority: 1,
        desc: "description #{next_week} #{:rand.normal()}"
      }

      Server.insert_event({event.date, event.name, event.recur, event.priority, event.desc})
      test_ets = :sys.get_state(fixture.rem_serv)

      assert :ets.match_object(test_ets, {{:"$1", next_week.month, next_week.day}, :"$2"}) ==
               Server.get_next_week()
    end
  end
end
