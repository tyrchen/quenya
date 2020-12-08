defmodule QuenyaTest.Parser do
  use ExUnit.Case
  doctest QuenyaParser

  alias QuenyaParser.Object.Parameter

  test "parse todo_full.yml" do
    {:ok, result} = QuenyaParser.parse("test/fixture/todo_full.yml")

    assert [%Parameter{name: "limit"}, %Parameter{name: "filter"}] =
             result.paths["/todos"]["get"].parameters
  end

  test "parse todo.yml" do
    {:ok, result} = QuenyaParser.parse("test/fixture/todo/main.yml")

    assert [%Parameter{name: "limit"}, %Parameter{name: "filter"}] =
             result.paths["/todos"]["get"].parameters
  end
end
