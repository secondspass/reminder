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
      # what i want to do here is start the genserver and get the event through the interface. Before that
      # get the event directly from the db. Then compare if the two results are the same
      # maybe use insert_event to insert an event for today, then use get_today to get that event and check if it is the same event inserted
      # we are only testing data storage and retrieval. No need to worry about today, tomorrow and all that, i think.
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
      assert Server.insert_event(event1.date, event1.name, event1.recur, event1.priority, event1.desc) == :inserted
      assert Server.insert_event(event2.date, event2.name, event2.recur, event2.priority, event2.desc) == :inserted
      # check if the event above has been inserted
      assert Server.insert_event(event1.date, event1.name, event1.recur, event1.priority, event1.desc) == :event_already_present
      # sync ets to dets on file
      Server.sync_to_dets()
      # since sync_to_dets is a cast (async operation), we need to force sync by calling :sys.get_state in order to properly open and check the dets to
      # see if the values from the ets were inserted
      test_ets = :sys.get_state(fixture.rem_serv)
      # need to use the already opened dets from the genserver to check the values, hence :reminders_dets
      assert :dets.lookup(:reminders_dets, event1.date) == :ets.lookup(test_ets, event2.date)

    end

    test "dets sync" do
      nil
    end
    
  end
end
