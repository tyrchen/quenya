defmodule PetstoreTest.Gen.GetOrderById do
  @moduledoc false
  use ExUnit.Case, async: true
  use Plug.Test
  use ExUnitProperties
  alias Quenya.{RequestHelper, ResponseHelper, TestHelper}
  alias ExJsonSchema.Validator
  @opts apply(Petstore.Gen.Router, :init, [[]])

  property("/store/order/{orderId}" <> ": should work") do
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
    "/store/order/{orderId}"
  end

  def content do
    %{}
  end

  def params do
    [
      %QuenyaBuilder.Object.Parameter{
        deprecated: false,
        description: "ID of pet that needs to be fetched",
        examples: [],
        explode: false,
        name: "orderId",
        position: "path",
        required: true,
        schema: %ExJsonSchema.Schema.Root{
          custom_format_validator: nil,
          location: :root,
          refs: %{},
          schema: %{"format" => "int64", "maximum" => 5, "minimum" => 1, "type" => "integer"}
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
              schema: %{
                "description" => "An order for a pets from the pet store",
                "properties" => %{
                  "complete" => %{"default" => false, "type" => "boolean"},
                  "id" => %{"format" => "int64", "type" => "integer"},
                  "petId" => %{"format" => "int64", "type" => "integer"},
                  "quantity" => %{"format" => "int32", "type" => "integer"},
                  "shipDate" => %{"format" => "date-time", "type" => "string"},
                  "status" => %{
                    "description" => "Order Status",
                    "enum" => ["placed", "approved", "delivered"],
                    "type" => "string"
                  }
                },
                "title" => "Pet Order",
                "type" => "object"
              }
            }
          }
        },
        description: "successful operation",
        headers: %{}
      },
      "400" => %QuenyaBuilder.Object.Response{
        content: %{},
        description: "Invalid ID supplied",
        headers: %{}
      },
      "404" => %QuenyaBuilder.Object.Response{
        content: %{},
        description: "Order not found",
        headers: %{}
      }
    }
  end

  def router_mod do
    Petstore.Gen.Router
  end
end
