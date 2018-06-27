defmodule Reminder.Mailer do
  def deliver(email) do
    Mailman.deliver(email, config())
  end

  def config do
    %Mailman.Context{
      config: nil,
      composer: %Mailman.EexComposeConfig{
        root_path: "",
  assets_path: "", 
  text_file: false,
  html_file: false,
  text_file_path: "",
  html_file_path: ""}
    }
  end
end
