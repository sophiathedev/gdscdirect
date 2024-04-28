defmodule GdscDirect.SlashCommand.Profile do
  # use embed for pretty view of profile
  import Nostrum.Struct.Embed

  # use database
  alias GdscDirect.Database
  alias Nostrum.Struct.User

  @moduledoc "Profile slash command for get profile of user"
  @behaviour Nosedrum.ApplicationCommand

  @doc "Description of command"
  @spec description() :: String.t()
  @impl true
  def description() do
    "Get profile of user"
  end

  @doc "Main engine for process the profile slash command"
  @impl true
  def command(interaction) do
    random_color = get_random_color()
    # user avt url
    # first get the user id
    avatar_url = interaction.user |> User.avatar_url("png")

    # get information from database
    user_db_info =
      Database.select(
        :user,
        [:credits, :visited, :visit_streak, :max_visit_streak],
        "where discord_id = '#{interaction.member.user_id}'"
      )
      |> Database.first_row()

    # all field by the order [:credits, :visited, :visit_streak, :max_visit_streak]
    user_credits = user_db_info |> Enum.at(0)

    user_visited_today =
      if user_db_info |> Enum.at(1) == 1, do: "Đã điểm danh", else: "Chưa điểm danh"

    user_visit_streak = user_db_info |> Enum.at(2)
    user_max_visit_streak = user_db_info |> Enum.at(3)

    # create the embed for easier view of profile
    embed =
      %Nostrum.Struct.Embed{}
      |> put_author("#{interaction.member.nick} (#{user_visited_today})", avatar_url, avatar_url)
      |> put_thumbnail(avatar_url)
      |> put_color(random_color)
      |> put_footer("GDSC Direct powered by Nostrum Elixir.")
      |> put_field("Credits", user_credits, true)
      |> put_field("Chuỗi điểm danh", user_visit_streak, true)
      |> put_field("Chuỗi dài nhất", user_max_visit_streak, true)

    [embeds: [embed]]
  end

  @impl true
  @doc "Define the type of ApplicationCommand is slash command"
  @spec type() :: :slash
  def type() do
    :slash
  end

  # function for get random embed color from google pallete
  defp get_random_color() do
    list_color = [0x4286F4, 0x34A853, 0xF9AA00, 0xEA4335]
    list_color |> Enum.shuffle() |> Enum.random()
  end
end
