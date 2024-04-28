defmodule GdscDirect.SlashCommand.Ping do
  @moduledoc "Ping slash command for get the bot latency"
  @behaviour Nosedrum.ApplicationCommand

  @doc "Description of command"
  @impl true
  @spec description() :: String.t()
  def description() do
    "Get bot latency"
  end

  @impl true
  def command(_interaction) do
    # get the bot latency using shard latencies from Nostrum.Util
    bot_latency = Nostrum.Util.get_all_shard_latencies() |> Map.values()
    bot_latency = Enum.sum(bot_latency) / length(bot_latency)
    [content: ":ping_pong: **Pong!** Latency: **#{bot_latency}ms**"]
  end

  # set the type of command is slash command
  @impl true
  @doc "Define the type of ApplicationCommand is slash command"
  @spec type() :: :slash
  def type() do
    :slash
  end
end
