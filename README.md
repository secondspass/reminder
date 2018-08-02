# Reminder

The goal is to have an app running in the background (daemon, if you will) that will
keep track of any events you have set and send reminders to your email. The event can be
defined as Priority 1 or Priority 2 and as recurring or non-recurring.

* Priority 1 - a reminder for this event will be sent on the day of the event and the day
  before. 
* Priority 2 - a reminder for this event will be sent one week before, one day before, and
  on the day of the event
* Recurring - a reminder for this event will be sent every year. Used for birthdays,
  anniversaries, etc.
* Non recurring - a reminder is sent only in the year of the date that is set. Used for
  one off events.
  
A GenServer maintains the ETS table with all the events. A Task is run every 24 hours to
check the table and send the reminders. You can set the time you want the reminder to be
sent in the config file. 

# Installation and running
1. Make sure you have Elixir 1.6 or above installed
2. Make sure you have created a csv file where each entry is in the format `event
   name,priority(1 or 2),recurring?(true or false),description`. See
   [exampleevents.csv](priv/exampleevents.csv) for an example.
3. Clone this repo
4. Create a file called `prod.secret.exs` in the `config` directory and insert the following into the file,
replacing the `<receiver>, <sender>, <sender password>` with the appropriate information
(Note that this is the config for gmail, but should work with any email provider that
provides smtp).
```elixir
use Mix.Config

config :reminder,
  to_email: "<receiver>@gmail.com",
  from_email: "<sender>@gmail.com"

config :mailman,
  relay: "smtp.gmail.com",
  username: "<sender>@gmail.com",
  password: "<sender password>",
  port: 587,
  tls: :always,
  auth: :always
```
5. Run `mix do deps.get, deps.compile, compile` in the project root directory.

# Running the app
All interactions with the app is through the `remapp.exs` script and the csv file.

1. To start the app in the background, run `elixir remapp.exs` inside the repo. If the
   app is already started, it exits with a message.

2. Once the app is started, you can add data from the csv file by running `elixir
   remapp.exs --csv <path to csv>`. If the app is not started, the command will start
   the app and then initialize it with the csv file.
3. If you want to add a new event, add it to the csv file and run the above command.
4. If you want to delete events, delete them in your csv file and then run `elixir
   remapp.exs --reset && elixir remapp.exs --csv <path to csv>`. This is a bit of a
   crude way to do things because it erases and rebuilds the internal ETS table from
   scratch but eh, it's good enough for now.
