defmodule Spidey.File do
  def save(urls, path) do
    content = Enum.join(urls, "\n")

    path
    |> File.open!([:utf8, :write])
    |> write(content)
  end

  def write(file, content) do
    try do
      IO.write(file, content)
    after
      File.close(file)
    end
  end
end
