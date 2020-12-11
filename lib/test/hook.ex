defmodule QuenyaTest.Hook do
  @moduledoc """
  This behavior should be implemented when you want to extend Quenya generated test cases.
  There are 3 hooks defined for you:

    - precondition: if you provided this function, quenya generated test will call this function before it
      applies the Router plug. You can prepare certain state for the test.
    - cleanup: if you provided this function, quenya generated test will call this function after test function
      is executed. You can cleanup the state if the API generates any.
    - mocks: if you provided this function, quenya generated test will use the mocks when executing the test
      function. mocks should return a list containing {Module, opts, functions}. For details, see:
      https://github.com/jjh42/mock#with_mocks---mocking-multiple-modules

  Note all these 3 hooks are optional.
  """
  @callback precondition() :: no_return()
  @callback cleanup() :: no_return()
  @callback mocks() :: list()
  @optional_callbacks precondition: 0, cleanup: 0, mocks: 0
end
