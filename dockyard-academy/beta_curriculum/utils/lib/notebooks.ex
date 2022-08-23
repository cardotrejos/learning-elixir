defmodule Utils.Notebooks do
  @minor_words ["and", "the", "in", "to", "of"]

  def stream_lines(file_names, function) do
    arity = :erlang.fun_info(function)[:arity]

    Stream.each(file_names, fn file_name ->
      file_name
      |> File.stream!([], :line)
      |> Stream.with_index()
      |> Stream.map(fn {line, index} ->
        case arity do
          1 -> function.(line)
          2 -> function.(line, line_number: index + 1, file_name: file_name)
        end
      end)
      |> Stream.run()
    end)
    |> Stream.run()
  end

  def all_livebooks do
    reading() ++ exercises() ++ ["../start.livemd"]
  end

  def reading do
    fetch_livebooks("../reading/")
  end

  def exercises do
    fetch_livebooks("../exercises/")
  end

  defp fetch_livebooks(path) do
    File.ls!(path)
    |> Stream.filter(&String.ends_with?(&1, ".livemd"))
    |> Enum.map(&(path <> &1))
  end

  @doc """
  Capitalize first letter of string without downcasing rest of string.

    ## Examples

      iex> Utils.Notebooks.capitalize_first("hello")
      "Hello"

      iex> Utils.Notebooks.capitalize_first("genServer")
      "GenServer"
  """
  def capitalize_first(str) do
    {first, rest} = String.split_at(str, 1)
    String.capitalize(first) <> rest
  end

  @doc """
  Convert string to title case downcasing minor words and capitalizing first letter of major words.

    ## Examples

    iex> Utils.Notebooks.to_title_case("bottles of soda")
    "Bottles of Soda"

    iex> Utils.Notebooks.to_title_case("my_function/1")
    "my_function/1"

    iex> Utils.Notebooks.to_title_case(":atom")
    ":atom"

    iex> Utils.Notebooks.to_title_case("Bottles Of Soda")
    "Bottles of Soda"
  """
  def to_title_case(str) do
    String.split(str)
    |> Enum.with_index()
    |> Enum.map(fn
      {word, index} ->
        cond do
          String.contains?(word, "/") ->
            word

          index == 0 ->
            capitalize_first(word)

          String.downcase(word) in @minor_words ->
            String.downcase(word)

          true ->
            capitalize_first(word)
        end
    end)
    |> Enum.join(" ")
  end
end
