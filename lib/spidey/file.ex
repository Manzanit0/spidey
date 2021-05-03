defmodule Spidey.File do
  @moduledoc """
  Soft wrapper around Elixir's `File` module for saving crawled urls to file.
  """

  @doc """
  Saves the list of files to the specified file.
  """
  @spec save([String.t()], String.t()) :: :ok | {:error, any()}
  def save(urls, path) do
    content = Enum.join(urls, "\n")

    path
    |> File.open!([:utf8, :write])
    |> write(content)
  end

  @doc """
  Writes the content to the file safely closing the file afterwards.
  """
  @spec write(File.io_device(), String.t()) :: :ok | {:error, any()}
  def write(file, content) do
    try do
      IO.write(file, content)
    after
      File.close(file)
    end
  end
end
