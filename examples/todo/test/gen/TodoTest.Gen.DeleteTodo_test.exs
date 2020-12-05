defmodule TodoTest.Gen.DeleteTodo do
  @moduledoc false
  use ExUnit.Case, async: true
  use Plug.Test
  use ExUnitProperties
  alias Quenya.{RequestHelper, ResponseHelper, TestHelper}
  alias ExJsonSchema.Validator
  @opts apply(Todo.Gen.Router, :init, [[]])

  property("/api/v1/todo/{todoId}" <> ": should work") do
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
            |> conn(uri, ResponseHelper.encode(type, data))
            |> put_req_header("content-type", type)
            |> put_req_header("accept", accept)
        end

      conn = Enum.reduce(req_headers, conn, fn {k, v}, acc -> put_req_header(acc, k, v) end)
      conn = conn |> RequestHelper.put_security_scheme(security_data())
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
    :delete
  end

  def path do
    "/api/v1/todo/{todoId}"
  end

  def content do
    %{}
  end

  def params do
    [
      %QuenyaBuilder.Object.Parameter{
        deprecated: false,
        description: "The id of the pet to retrieve",
        examples: [],
        explode: false,
        name: "todoId",
        position: "path",
        required: true,
        schema: %ExJsonSchema.Schema.Root{
          custom_format_validator: nil,
          location: :root,
          refs: %{},
          schema: %{"format" => "uuid", "type" => "string"}
        },
        style: "simple"
      }
    ]
  end

  def res do
    %{
      "204" => %QuenyaBuilder.Object.Response{
        content: %{},
        description: "No content",
        headers: %{}
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
    {%QuenyaBuilder.Object.SecurityScheme{
       bearerFormat: "JWT",
       description: "",
       name: "",
       position: "",
       scheme: "bearer",
       type: "http"
     }, []}
  end
end
