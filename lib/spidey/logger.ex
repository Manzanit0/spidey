defmodule Spidey.Logger do
  @moduledoc """
  This module is to enable the configuration of logging levels.
  """

  require Logger

  def log(message) do
    default_level = :debug

    case Application.get_env(:spidey, :log, default_level) do
      false ->
        :ok

      true ->
        Logger.log(default_level, message)

      level ->
        Logger.log(level, message)
    end
  end
end
