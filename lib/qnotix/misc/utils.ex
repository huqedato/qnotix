defmodule Qnotix.Utils do
  @moduledoc false
  def randomString(c \\ 20) do
    for _ <- 1..c,
        into: "",
        do: <<Enum.random('0123456789qwertyuiopasdfghjklzxcvbnmABCDEFGHIJKLMNOPQRSTUVWXYZ')>>
  end

  def timestamp do
    DateTime.utc_now() |> DateTime.to_unix()
  end

  def msgValability, do: Application.get_env(:qnotix, :msgDeadAfter) * 60 * 60 * 24
end
