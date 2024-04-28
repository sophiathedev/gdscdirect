defmodule GdscDirect.SlashCommand.Transaction do
  @moduledoc """
  Transaction slash command for doing the transaction for transfer credits to user
  """
  alias GdscDirect.Database
  @behaviour Nosedrum.ApplicationCommand

  @doc "Description of command"
  @impl true
  @spec description() :: String.t()
  def description do
    "Doing the transaction for transfer credits to specific user"
  end

  @impl true
  def command(interaction) do
    [
      %{name: "user", value: user_provided},
      %{name: "amount", value: credits_amount},
      %{name: "reason", value: transaction_reason}
    ] = interaction.data.options

    if user_provided == interaction.member.user_id do
      handle_duplicate_author_and_user_provided(
        interaction.member.user_id,
        user_provided,
        credits_amount,
        transaction_reason
      )
    else
      handle_transaction(
        interaction.member.user_id,
        user_provided,
        credits_amount,
        transaction_reason
      )
    end
  end

  # this function will handle the event if from_id is equal to_id called this is duplicate author and user provided
  defp handle_duplicate_author_and_user_provided(_from_id, _to_id, _amount, _reason) do
    [
      content:
        "**Bạn không thể tự chuyển cho chính mình**, bạn đang không trung thực nên GDSC sẽ thưởng cho bạn **-5** Credit nhé",
      ephemeral?: true
    ]
  end

  # this function will handle the event that opposite the handle_duplicate_author_and_user_provided, this event is main function for command
  defp handle_transaction(from_id, to_id, amount, reason) do
    Database.insert(:cred_transaction, [:from_id, :to_id, :amount, :reason], [
      "\'#{from_id}\'",
      "\'#{to_id}\'",
      amount,
      "\'#{reason}\'"
    ])

    Database.update(:user, [:credits], ["credits + #{amount}"], "where discord_id = \'#{to_id}\'")

    [
      content: "**Giao dịch thành công ! :partying_face:**"
    ]
  end

  @impl true
  @doc "define the options required by application command"
  def options() do
    [
      %{
        type: :user,
        name: "user",
        description: "User provided for transfer credits",
        required: true
      },
      %{
        type: :integer,
        name: "amount",
        description: "Amount of credits",
        required: true
      },
      %{
        type: :string,
        name: "reason",
        description: "Reason for why transfer credits into user",
        required: true
      }
    ]
  end

  @impl true
  @doc "Define the type of ApplicationCommand is slash command"
  @spec type() :: :slash
  def type do
    :slash
  end
end
