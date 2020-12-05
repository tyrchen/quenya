defmodule TodoTest.Gen.ListTodos do
  @moduledoc false
  use ExUnit.Case, async: true
  use Plug.Test
  use ExUnitProperties
  alias Quenya.{RequestHelper, ResponseHelper, TestHelper}
  alias ExJsonSchema.Validator
  @opts apply(Todo.Gen.Router, :init, [[]])

  property("/api/v1/todos" <> ": should work") do
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
            |> RequestHelper.put_security_scheme(security_data())
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
    "/api/v1/todos"
  end

  def content do
    %{}
  end

  def params do
    [
      %QuenyaBuilder.Object.Parameter{
        deprecated: false,
        description: "how many items to return at one time * default: 10 * min: 10 * max: 100\n",
        examples: [],
        explode: false,
        name: "limit",
        position: "query",
        required: false,
        schema: %ExJsonSchema.Schema.Root{
          custom_format_validator: nil,
          location: :root,
          refs: %{},
          schema: %{
            "default" => 10,
            "format" => "int32",
            "maximum" => 100,
            "minimum" => 10,
            "type" => "integer"
          }
        },
        style: "simple"
      },
      %QuenyaBuilder.Object.Parameter{
        deprecated: false,
        description:
          "filter type:\n  * `all`: default, show all items\n  * `active`: show active todo items\n  * `completed`: show completed todo items\n",
        examples: [],
        explode: false,
        name: "filter",
        position: "query",
        required: false,
        schema: %ExJsonSchema.Schema.Root{
          custom_format_validator: nil,
          location: :root,
          refs: %{},
          schema: %{
            "default" => "all",
            "enum" => ["all", "active", "completed"],
            "type" => "string"
          }
        },
        style: "simple"
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
              schema: %{
                "items" => %{
                  "example" => %{
                    "body" => "hello world!",
                    "created" => "2020-11-11T17:32:28Z",
                    "id" => "16ba8d00-d44c-4f61-841f-2da8221091bc",
                    "status" => "active",
                    "updated" => "2020-11-11T19:32:28Z"
                  },
                  "properties" => %{
                    "body" => %{"maxLength" => 140, "minLength" => 3, "type" => "string"},
                    "created" => %{"format" => "date-time", "type" => "string"},
                    "id" => %{"format" => "uuid", "type" => "string"},
                    "status" => %{"enum" => ["active", "completed"], "type" => "string"},
                    "updated" => %{"format" => "date-time", "type" => "string"}
                  },
                  "required" => ["body"],
                  "type" => "object"
                },
                "type" => "array"
              }
            }
          }
        },
        description: "a paged array of todo items",
        headers: %{
          "x-cursor" => %QuenyaBuilder.Object.Header{
            deprecated: false,
            description: "cursor for next page",
            examples: [],
            explode: false,
            required: true,
            schema: %ExJsonSchema.Schema.Root{
              custom_format_validator: nil,
              location: :root,
              refs: %{},
              schema: %{"type" => "string"}
            },
            style: "simple"
          }
        }
      },
      "default" => %QuenyaBuilder.Object.Response{
        content: %{
          "application/json" => %QuenyaBuilder.Object.MediaType{
            examples: [],
            schema: %ExJsonSchema.Schema.Root{
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
  end

  def router_mod do
    Todo.Gen.Router
  end

  def security_data do
    nil
  end
end
