defmodule Todo.Gen.ListTodos.FakeHandler do
  @moduledoc false
  use ExUnit.Case, async: true
  use ExUnitProperties
  alias Quenya.TestHelper
  alias ExJsonSchema.Validator

  method = :get
  content = nil

  params = [
    %{
      __struct__: QuenyaBuilder.Object.Parameter,
      deprecated: false,
      description: "how many items to return at one time * default: 10 * min: 10 * max: 100\n",
      examples: [],
      explode: false,
      name: "limit",
      position: "query",
      required: false,
      schema: %{
        __struct__: ExJsonSchema.Schema.Root,
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
      style: :simple
    },
    %{
      __struct__: QuenyaBuilder.Object.Parameter,
      deprecated: false,
      description:
        "filter type:\n  * `all`: default, show all items\n  * `active`: show active todo items\n  * `completed`: show completed todo items\n",
      examples: [],
      explode: false,
      name: "filter",
      position: "query",
      required: false,
      schema: %{
        __struct__: ExJsonSchema.Schema.Root,
        custom_format_validator: nil,
        location: :root,
        refs: %{},
        schema: %{
          "default" => "all",
          "enum" => ["all", "active", "completed"],
          "type" => "string"
        }
      },
      style: :simple
    }
  ]

  res = %{
    "200" => %{
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
        "X-Cursor" => %{
          __struct__: QuenyaBuilder.Object.Header,
          deprecated: false,
          description: "cursor for next page",
          examples: [],
          explode: false,
          required: true,
          schema: %{
            __struct__: ExJsonSchema.Schema.Root,
            custom_format_validator: nil,
            location: :root,
            refs: %{},
            schema: %{"type" => "string"}
          },
          style: :simple
        }
      }
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
