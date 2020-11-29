defmodule QuenyaTest.Parser do
  use ExUnit.Case
  doctest Quenya.Parser

  test "parse todo_full.yml" do
    {:ok, result} = Quenya.Parser.parse("test/fixture/todo_full.yml")

    assert [%{"name" => "limit"}, %{"name" => "filter"}] =
             result["paths"]["/todos"]["get"]["parameters"]
  end

  test "parse todo.yml" do
    {:ok, result} = Quenya.Parser.parse("test/fixture/todo/main.yml")

    assert [%{"name" => "limit"}, %{"name" => "filter"}] =
             result["paths"]["/todos"]["get"]["parameters"]
  end
end
