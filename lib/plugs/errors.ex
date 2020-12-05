defmodule Quenya.Plug.UnauthenticatedError do
  @moduledoc """
  The request will not be processed due to unauthenticated.
  """

  defexception message: "unauthenticated", plug_status: 401
end

defmodule Quenya.Plug.UnauthorizedError do
  @moduledoc """
  The request will not be processed due to unauthorized.
  """

  defexception message: "unauthorized", plug_status: 403
end
