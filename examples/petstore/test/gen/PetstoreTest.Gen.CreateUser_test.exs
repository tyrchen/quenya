defmodule PetstoreTest.Gen.CreateUser do
  @moduledoc false
  use ExUnit.Case, async: true
  use Plug.Test
  use ExUnitProperties
  alias Quenya.{RequestHelper, ResponseHelper, TestHelper}
  alias ExJsonSchema.Validator
  @opts apply(Petstore.Gen.Router, :init, [[]])

  property("/user" <> ": should work") do
    check(
      all(
        uri <- TestHelper.stream_gen_uri(path(), params()),
        req_headers <- TestHelper.stream_gen_req_headers(params()),
        req_body <- TestHelper.stream_gen_req_body(content()),
        {code, res_header_schemas, accept, res_body_schema} <- TestHelper.stream_gen_res(res())
      )
    ) do
      conn =
        case(req_body) do
          nil ->
            conn(method(), uri)

          {type, data} ->
            method()
            |> conn(uri, Jason.encode!(data))
            |> put_req_header("content-type", type)
            |> put_req_header("accept", accept)
        end

      conn = Enum.reduce(req_headers, conn, fn {k, v}, acc -> put_req_header(acc, k, v) end)
      conn = apply(router_mod(), :call, [conn, @opts])
      assert(conn.status == code)

      case(ResponseHelper.decode(accept, conn.resp_body)) do
        "" ->
          nil

        v ->
          assert(Validator.valid?(res_body_schema, v))
      end

      Enum.map(res_header_schemas, fn {name, schema} ->
        assert(
          Validator.valid?(
            schema,
            RequestHelper.get_param(conn, name, "resp_header", schema.schema)
          )
        )
      end)
    end
  end

  def method do
    :post
  end

  def path do
    "/user"
  end

  def content do
    %{
      "application/json" => %QuenyaBuilder.Object.MediaType{
        examples: [],
        schema: %ExJsonSchema.Schema.Root{
          custom_format_validator: nil,
          location: :root,
          refs: %{},
          schema: %{
            "description" => "A User who is purchasing from the pet store",
            "properties" => %{
              "email" => %{"type" => "string"},
              "firstName" => %{"type" => "string"},
              "id" => %{"format" => "int64", "type" => "integer"},
              "lastName" => %{"type" => "string"},
              "password" => %{"type" => "string"},
              "phone" => %{"type" => "string"},
              "userStatus" => %{
                "description" => "User Status",
                "format" => "int32",
                "type" => "integer"
              },
              "username" => %{"type" => "string"}
            },
            "title" => "a User",
            "type" => "object"
          }
        }
      }
    }
  end

  def params do
    []
  end

  def res do
    %{
      "201" => %QuenyaBuilder.Object.Response{
        content: %{},
        description: "successful operation",
        headers: %{}
      }
    }
  end

  def router_mod do
    Petstore.Gen.Router
  end
end
