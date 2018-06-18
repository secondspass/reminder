defmodule Reminder.Mailer do
    def deliver(email) do
      Mailman.deliver(email, config())
    end

    def config do
      %Mailman.Context{
        config: nil,
        composer: %Mailman.EexComposeConfig{}
      }
    end
end
