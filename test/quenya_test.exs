defmodule QuenyaTest do
  use ExUnit.Case
  doctest Quenya

  test "greets the world" do
    assert Quenya.hello() == :world
  end
end
