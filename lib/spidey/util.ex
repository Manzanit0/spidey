defmodule Spidey.Util do
  @doc """
  Simple diffing function to time short snippets of code using
  DateTime.utc_now/0.

  Take into account that it's just to get ballpark numbers. The approach is
  inherently broken.

  ## Example

  iex> t0 = DateTime.utc_now()
  iex> t1 = DateTime.utc_now()
  iex> diff(t0, t1)
  0.02
  """
  def diff(%DateTime{} = t0, %DateTime{} = t1) do
    minutes = t1.minute - t0.minute
    seconds = t1.second + minutes * 60 - t0.second
    microseconds = elem(t1.microsecond, 0) + seconds * 1_000_000 - elem(t0.microsecond, 0)

    microseconds / 1_000
  end
end
