defmodule GdscDirect.Forms.DailyVisit do
  alias GdscDirect.Database
  alias Nostrum.Api
  alias Nostrum.Struct.Component

  require Logger

  # get guild_id from application environment
  # get channel for application initialize the form
  @init_form_channel Application.compile_env!(:gdsc_direct, [
                       :global_conf,
                       :init_daily_visit_channel
                     ])

  def initialize() do
    Api.create_message!(@init_form_channel,
      content:
        "Đây sẽ là nút để các bạn có thể điểm danh hàng ngày, bằng cách **nhấn cái nút ở bên dưới** !\n\n**#vi_social_credits**\n",
      components: [
        Component.ActionRow.action_row(
          components: [
            Component.Button.interaction_button("Điểm danh", "daily_visit_button", style: 4)
          ]
        )
      ]
    )
  end

  @spec handle_event(Nostrum.Struct.Interaction.t()) :: {:ok}
  def handle_event(interaction) do
    # handle if the user already visited
    already_visited =
      Database.select(:user, [:visited], "where discord_id = \'#{interaction.member.user_id}\'")
      |> Database.first_row()
      |> Enum.at(0)

    if already_visited == 1,
      do: handle_event_already_visited(interaction),
      else: handle_event_default(interaction)
  end

  @doc "this function will handle the event that user already visited on a day"
  @spec handle_event_already_visited(Nostrum.Struct.Interaction.t()) :: {:ok}
  def handle_event_already_visited(interaction) do
    # create mention message
    user_mention = interaction.member |> Nostrum.Struct.Guild.Member.mention()

    # logger warning that a user tried visited twice a day
    Logger.warning("#{interaction.member.nick} tried to visit twice a day")

    Api.create_interaction_response(interaction, %{
      type: 4,
      data: %{
        content: "#{user_mention}\n#{random_already_visit_complete()}",
        flags: GdscDirect.Constants.MessageFlags.ephemeral()
      }
    })
  end

  @spec handle_event_default(Nostrum.Struct.Interaction.t()) :: {:ok}
  def handle_event_default(interaction) do
    # update the streak first is solved the problem
    Database.update(
      :user,
      [:visit_streak],
      ["visit_streak + 1"],
      "where discord_id = '#{interaction.member.user_id}' and visited = 0"
    )

    # update visited today
    Database.update(:user, [:visited], [1], "where discord_id = '#{interaction.member.user_id}'")

    # udpate the max streak visited
    Database.update(:user, [:max_visit_streak], ["max(max_visit_streak, visit_streak)"])

    # create mention message
    user_mention = Nostrum.Struct.Guild.Member.mention(interaction.member)

    # logger that user visited
    Logger.info("#{interaction.member.nick} confirm visitied")

    # response annouce that user been visited
    Api.create_interaction_response(interaction, %{
      type: 4,
      data: %{
        content: "#{user_mention}\n#{random_visit_complete()}",
        flags: GdscDirect.Constants.MessageFlags.ephemeral()
      }
    })
  end

  # function for get random message w hen user already visitied but tried visited again
  defp random_already_visit_complete do
    list_msg = [
      "Eo ôi, tham thế, đã điểm danh rồi mà vẫn muốn điểm danh nữa hả?",
      "Bộ bạn thiếu Social Credits lắm hả? Đợi đến mai rồi điểm danh lại nè!"
    ]

    list_msg |> Enum.shuffle() |> Enum.random()
  end

  # function for get random message when user visited complete
  defp random_visit_complete() do
    list_msg = [
      "Bravo! **Cố gắng duy trì mỗi ngày nhé !**",
    ]

    list_msg |> Enum.shuffle() |> Enum.random()
  end
end
