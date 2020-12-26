defmodule ExScapper do
  alias ExScapper.Templater
  @moduledoc """
  Documentation for `ExScapper`.
  """

  def execute() do
    get_answer_list()
    |> Enum.each(fn file_name ->
      fetch_data_from_gh(file_name)
    end)
  end

  def fetch_data_from_gh(file_name) do
    Task.start(fn -> build_solution(file_name) end)
  end

  def get_answer_list() do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get("https://api.github.com/repos/ghostdsb/ProjectEuler/contents"),
    {:ok, data} <- Jason.decode(body) do
      data
      |> Enum.map(fn entry -> entry["name"] end)
      |> Enum.filter(fn x -> is_answer?(x) end)
    else
      _ -> "err"
    end
  end

  def build_solution(file_name) do
    "pe" <> question_number = file_name |> String.split("-") |> hd
    question = get_question(question_number)
    answer_data = get_answer_data(file_name, :untimed)
    {{year, month, date}, {hour, min, sec}} = answer_data["headers"]["last-modified"]
    |> Timex.parse!("{RFC1123}")
    |> Timex.to_datetime
    |> Timex.add(Timex.Duration.from_minutes(330))
    |> Timex.to_erl

    post = Templater.make_post(%{
      "question_number" => question_number,
      "question" => question,
      "answer" => answer_data["body"],
      "last-modified" => "#{year}-#{month}-#{date} #{hour}:#{min}:#{sec} +0530"
    })
    File.write("/home/tenzin/Documents/ghostdsb.github.io/euler/_posts/#{year}-#{month}-#{date}-project-euler-#{question_number}.md", post, [:utf8])
  end

  def get_answer_data(file_name, :timed) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} <- HTTPoison.get("https://api.github.com/repos/ghostdsb/ProjectEuler/contents/"<>file_name<>"?ref=master") do
      {:ok, data} = body |> Jason.decode()
      data =
        data["content"]
        |> String.split("\n")
        |> Enum.map(fn line -> line |> Base.decode64!() end)
        |> Enum.join()
      file_name |> IO.inspect()
        %{
        "body" => data,
        "headers" => headers |> Map.new()
      }
    else
      _ ->
      %{
        "body" => "#error",
        "headers" => %{"last-modified" => "error"}
      }
    end
  end

  def get_answer_data(file_name, :untimed) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get("https://raw.githubusercontent.com/ghostdsb/ProjectEuler/master/"<>file_name) do
      file_name |> IO.inspect()
        %{
        "body" => body,
        "headers" => %{"last-modified" => "Thu, 02 Nov 2017 09:53:25 GMT"}
      }
    else
      _ ->
        %{
          "body" => "#error",
          "headers" => %{"last-modified" => "error"}
      }
    end
  end

  def get_question(question_number) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get("https://projecteuler.net/problem=" <> question_number) do

      title = body
      |> Floki.find("h2")
      |> Enum.map(fn content -> htmlfy(content) end)
      |> List.first()

      question = body
      |> Floki.find("div.problem_content")
      |> Enum.map(fn content -> htmlfy(content) end)
      |> List.first()

      %{"title" => title,
      "content" => question}
    else
      _ -> %{"title" => "<h2>question-title</h2>", "content" => "<div>question-body</div>"}
    end
  end

  def htmlfy({tag_name, _attributes, []}) do
    "<#{tag_name}/>"
  end
  def htmlfy({tag_name, _attributes, children_nodes}) do
    "<#{tag_name}>#{Enum.reduce(children_nodes,"",fn child, acc -> acc <> htmlfy(child) end )}</#{tag_name}>"
  end

  def htmlfy(string_child), do: string_child

  defp is_answer?(string) do
    String.contains?(string, "pe")
  end


end
