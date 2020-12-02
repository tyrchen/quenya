defmodule Todo.Gen.DeleteTodo.FakeHandler do
  @moduledoc false
  use ExUnit.Case, async: true
  use ExUnitProperties
  alias Quenya.TestHelper
  alias ExJsonSchema.Validator

  method = :delete
  content = nil
  params = []

  res = %{
    "204" => %{
      __struct__: QuenyaBuilder.Object.Response,
      content: %{},
      description: "No content",
      headers: %{}
    },
    "default" => %{
      __struct__: QuenyaBuilder.Object.Response,
      content: %{
        "application/json" => %{
          __struct__: QuenyaBuilder.Object.MediaType,
          examples: [],
          schema: %{
            __struct__: ExJsonSchema.Schema.Root,
            custom_format_validator: nil,
            location: :root,
            refs: %{},
            schema: %{
              "properties" => %{
                "code" => %{"format" => "int32", "type" => "integer"},
                "message" => %{"type" => "string"}
              },
              "required" => ["code", "message"],
              "type" => "object"
            }
          }
        }
      },
      description: "unexpected error",
      headers: %{}
    }
  }

  property("#{unquote(path)}: should work") do
    check(
      all(
        uri <- TestHelper.stream_gen_uri(unquote(path), params),
        req_headers <- TestHelper.stream_gen_req_headers(params),
        req_body <- TestHelper.stream_gen_req_body(content),
        res_header_schemas <- TestHelper.stream_gen_res_headers(res.headers),
        {code, accept, res_body_schema} <- TestHelper.stream_gen_res_body(res.responses)
      )
    ) do
      {status, headers, body} =
        case(req_body) do
          nil ->
            conn(method, uri)

          {type, data} ->
            method
            |> conn(uri, Jason.encode!(data))
            |> put_req_header("content-type", type)
            |> put_req_header("accept", accept)
        end
        |> Enum.reduce(headers, conn, fn {k, v}, acc -> put_req_header(acc, k, v) end)
        |> sent_resp()

      assert(status == code)
      assert(Validator.valid?(res_body_schema, body))
      Enum.map(headers, fn {k, v} -> assert(Validator.valid?(res_header_schemas[k], v)) end)
    end
  end
end
