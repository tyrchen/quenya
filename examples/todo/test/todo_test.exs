defmodule TodoTest do
  use ExUnit.Case
  doctest Todo

  test "greets the world" do
    assert Todo.hello() == :world
  end
end
