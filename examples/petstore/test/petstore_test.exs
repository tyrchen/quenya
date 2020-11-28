defmodule PetstoreTest do
  use ExUnit.Case
  doctest Petstore

  test "greets the world" do
    assert Petstore.hello() == :world
  end
end
