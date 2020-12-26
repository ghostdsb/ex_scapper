defmodule ExScapperTest do
  use ExUnit.Case
  doctest ExScapper

  test "greets the world" do
    assert ExScapper.hello() == :world
  end
end
