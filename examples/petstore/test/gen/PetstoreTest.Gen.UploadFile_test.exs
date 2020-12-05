defmodule PetstoreTest.Gen.UploadFile do
  @moduledoc false
  use ExUnit.Case, async: true
  use Plug.Test
  use ExUnitProperties
  alias Quenya.{RequestHelper, ResponseHelper, TestHelper}
  alias ExJsonSchema.Validator
  @opts apply(Petstore.Gen.Router, :init, [[]])

  property("/pet/{petId}/uploadImage" <> ": should work") do
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
    :post
  end

  def path do
    "/pet/{petId}/uploadImage"
  end

  def content do
    %{
      "multipart/form-data" => %QuenyaBuilder.Object.MediaType{
        examples: [],
        schema: %ExJsonSchema.Schema.Root{
          custom_format_validator: nil,
          location: :root,
          refs: %{},
          schema: %{
            "properties" => %{
              "additionalMetadata" => %{
                "description" => "Additional data to pass to server",
                "type" => "string"
              },
              "file" => %{
                "description" => "file to upload",
                "format" => "binary",
                "type" => "string"
              }
            },
            "type" => "object"
          }
        }
      }
    }
  end

  def params do
    [
      %QuenyaBuilder.Object.Parameter{
        deprecated: false,
        description: "ID of pet to update",
        examples: [],
        explode: false,
        name: "petId",
        position: "path",
        required: true,
        schema: %ExJsonSchema.Schema.Root{
          custom_format_validator: nil,
          location: :root,
          refs: %{},
          schema: %{"format" => "int64", "type" => "integer"}
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
                "description" => "Describes the result of uploading an image resource",
                "properties" => %{
                  "code" => %{"format" => "int32", "type" => "integer"},
                  "message" => %{"type" => "string"},
                  "type" => %{"type" => "string"}
                },
                "title" => "An uploaded response",
                "type" => "object"
              }
            }
          }
        },
        description: "successful operation",
        headers: %{}
      }
    }
  end

  def router_mod do
    Petstore.Gen.Router
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
