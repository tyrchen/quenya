defmodule TodoTest.Hooks do
  @moduledoc """
  TodoTest.Hooks keeps all the user defined hooks. It should implement
  `QuenyaTest.Hook` behavior:

    - precondition: if you provided this function, quenya generated test will call this function before it
      applies the Router plug. You can prepare certain state for the test.
    - cleanup: if you provided this function, quenya generated test will call this function after test function
      is executed. You can cleanup the state if the API generates any.
    - mocks: if you provided this function, quenya generated test will use the mocks when executing the test
      function. mocks should return a list containing {Module, opts, functions}. For details, see:
      https://github.com/jjh42/mock#with_mocks---mocking-multiple-modules

  You could add a submodule inside this module. The name of the module should be the operationId in PASCAL form, e.g.:

      defmodule GetTodo do
        def precondition, do: generate_todo_items()
        def cleanup, do: cleanup_todo_items()
        def mocks do
          [
            Repo, [], [get_by: fn _, _ -> data() end]
          ]
        end
      end
  """
  alias QuenyaTest.Hook

  defmodule CreateTodo do
    @behaviour Hook

    def precondition do
      IO.puts("Setting up data for the test")
    end

    def hooks do
      []
    end

    def cleanup do
      IO.puts("clean up the data used for test")
    end
  end

end
