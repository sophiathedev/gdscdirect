defmodule GdscDirect.Consumer do
  # define the consumer for discord nostrum
  use Nostrum.Consumer

  # require the logger for logging out information
  require Logger

  # get guild_id from application environment
  @guild_id Application.compile_env!(:gdsc_direct, [:global_conf, :guild_id])

  # when ready create the slash command
  def handle_event({:READY, _ready, _ws_state}) do
    slash_cmd = [
      Nosedrum.Storage.Dispatcher.add_command("ping", GdscDirect.SlashCommand.Ping, @guild_id),
      Nosedrum.Storage.Dispatcher.add_command(
        "profile",
        GdscDirect.SlashCommand.Profile,
        @guild_id
      )
      # temporary disabled the transaction command
      # Nosedrum.Storage.Dispatcher.add_command("transaction", GdscDirect.SlashCommand.Transaction, @guild_id)
    ]

    slash_cmd
    |> Enum.each(fn slash ->
      case slash do
        {:ok, cmd} -> Logger.info("Registered \"#{cmd.name}\" slash command")
        e -> Logger.error("An error occurred when registering Ping slash command: #{inspect(e)}")
      end
    end)

    GdscDirect.Forms.DailyVisit.initialize()
  end

  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) when interaction.type == 3 do
    case interaction.data.custom_id do
      "daily_visit_button" -> GdscDirect.Forms.DailyVisit.handle_event(interaction)
      _ -> raise("Error occurred when response interaction")
    end
  end

  # handle the event then a slash interaction created
  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) when interaction.type == 2 do
    Nosedrum.Storage.Dispatcher.handle_interaction(interaction)
  end

  def handle_event(_) do
    :noop
  end
end
