defmodule PetstoreTest.Gen.LoginUser do
  @moduledoc false
  use ExUnit.Case, async: true
  use Plug.Test
  use ExUnitProperties
  alias Quenya.{RequestHelper, ResponseHelper, TestHelper}
  alias ExJsonSchema.Validator
  @opts apply(Petstore.Gen.Router, :init, [[]])

  property("/user/login" <> ": should work") do
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
    :get
  end

  def path do
    "/user/login"
  end

  def content do
    %{}
  end

  def params do
    [
      %QuenyaBuilder.Object.Parameter{
        deprecated: false,
        description: "The user name for login",
        examples: [],
        explode: false,
        name: "username",
        position: "query",
        required: true,
        schema: %ExJsonSchema.Schema.Root{
          custom_format_validator: nil,
          location: :root,
          refs: %{},
          schema: %{
            "pattern" => "^[a-zA-Z0-9]+[a-zA-Z0-9\\.\\-_]*[a-zA-Z0-9]+$",
            "type" => "string"
          }
        },
        style: :simple
      },
      %QuenyaBuilder.Object.Parameter{
        deprecated: false,
        description: "The password for login in clear text",
        examples: [],
        explode: false,
        name: "password",
        position: "query",
        required: true,
        schema: %ExJsonSchema.Schema.Root{
          custom_format_validator: nil,
          location: :root,
          refs: %{},
          schema: %{"type" => "string"}
        },
        style: :simple
      }
    ]
  end

  def res do
    %{
      "200" => %QuenyaBuilder.Object.Response{
        content: %{
          "application/json" => %QuenyaBuilder.Object.MediaType{
            examples: [],
            schema: %ExJsonSchema.Schema.Root{
              custom_format_validator: nil,
              location: :root,
              refs: %{},
              schema: %{"type" => "string"}
            }
          }
        },
        description: "successful operation",
        headers: %{
          "set-cookie" => %QuenyaBuilder.Object.Header{
            deprecated: false,
            description:
              "Cookie authentication key for use with the `api_key` apiKey authentication.",
            examples: [],
            explode: false,
            required: false,
            schema: %ExJsonSchema.Schema.Root{
              custom_format_validator: nil,
              location: :root,
              refs: %{},
              schema: %{"type" => "string"}
            },
            style: :simple
          },
          "x-expires-after" => %QuenyaBuilder.Object.Header{
            deprecated: false,
            description: "date in UTC when toekn expires",
            examples: [],
            explode: false,
            required: false,
            schema: %ExJsonSchema.Schema.Root{
              custom_format_validator: nil,
              location: :root,
              refs: %{},
              schema: %{"format" => "date-time", "type" => "string"}
            },
            style: :simple
          },
          "x-rate-limit" => %QuenyaBuilder.Object.Header{
            deprecated: false,
            description: "calls per hour allowed by the user",
            examples: [],
            explode: false,
            required: false,
            schema: %ExJsonSchema.Schema.Root{
              custom_format_validator: nil,
              location: :root,
              refs: %{},
              schema: %{"format" => "int32", "type" => "integer"}
            },
            style: :simple
          }
        }
      },
      "400" => %QuenyaBuilder.Object.Response{
        content: %{},
        description: "Invalid username/password supplied",
        headers: %{}
      }
    }
  end

  def router_mod do
    Petstore.Gen.Router
  end
end
