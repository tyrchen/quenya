defmodule QuenyaTest.HookHelper do
  @moduledoc """
  Helper functions for test hook
  """

  def ensure_loaded(mod) do
    Code.ensure_loaded(mod)
  end

  def run_precondition(mod) do
    if hook_exists?(mod, :precondition) do
      apply(mod, :precondition, [])
    end
  end

  def get_mocks(mod) do
    case hook_exists?(mod, :mocks) do
      true -> apply(mod, :mocks, [])
      _ -> []
    end
  end

  def run_cleanup(mod) do
    if hook_exists?(mod, :cleanup) do
      apply(mod, :cleanup, [])
    end
  end

  defp hook_exists?(mod, fname) do
    function_exported?(mod, fname, 0)
  end
end
