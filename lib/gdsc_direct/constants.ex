defmodule GdscDirect.Constants.MessageFlags do
  import Bitwise

  @spec crossposted() :: 1
  def crossposted, do: 1 <<< 0

  @spec is_crosspost() :: 2
  def is_crosspost, do: 1 <<< 1

  @spec suppress_embeds() :: 4
  def suppress_embeds, do: 1 <<< 2

  @spec source_message_deleted() :: 8
  def source_message_deleted, do: 1 <<< 3

  @spec urgent() :: 16
  def urgent, do: 1 <<< 4

  @spec has_thread() :: 32
  def has_thread, do: 1 <<< 5

  @spec ephemeral() :: 64
  def ephemeral, do: 1 <<< 6

  @spec loading() :: 128
  def loading, do: 1 <<< 7

  @spec failed_to_mention_some_roles_in_thread() :: 256
  def failed_to_mention_some_roles_in_thread, do: 1 <<< 8

  @spec suppress_notifications() :: 4096
  def suppress_notifications, do: 1 <<< 12

  @spec is_voice_message() :: 8192
  def is_voice_message, do: 1 <<< 13
end
