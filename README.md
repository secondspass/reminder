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
sent in the config file. Another Task is run every month to remove obsolete events
(i.e. the past non recurring events) from the table.

# Entering your reminders
You can do it in the commandline interface one by one or by specifying a csv file where
each entry is in the format `event name,priority(1 or 2),recurring?(true or false),description`.

# Installation

Still working on it.

