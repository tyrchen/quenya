defmodule QuenyaTest.Parser do
  use ExUnit.Case
  doctest QuenyaParser

  test "parse todo_full.yml" do
    {:ok, result} = QuenyaParser.parse("test/fixture/todo_full.yml")

    assert [%{"name" => "limit"}, %{"name" => "filter"}] =
             result["paths"]["/todos"]["get"]["parameters"]
  end

  test "parse todo.yml" do
    {:ok, result} = QuenyaParser.parse("test/fixture/todo/main.yml")

    assert [%{"name" => "limit"}, %{"name" => "filter"}] =
             result["paths"]["/todos"]["get"]["parameters"]
  end
end
