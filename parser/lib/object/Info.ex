defmodule QuenyaParser.Object.Info do
  @moduledoc """
  Info object
  """
  use TypedStruct
  alias QuenyaParser.Object.{Contact, Info, License}

  typedstruct do
    @typedoc "Info object from the spec"
    field(:title, String.t(), enforce: true)
    field(:summary, String.t(), default: "")
    field(:description, String.t(), default: "")
    field(:terms_of_service, String.t(), default: "")
    field(:license, License.t())
    field(:contact, Contact.t())
    field(:version, String.t(), enforce: true)
  end

  def new(data) do
    %Info {
      title: data["title"],
      summary: data["summary"],
      description: data["description"],
      terms_of_service: data["terms_of_service"],
      license: License.new(data["license"]),
      contact: Contact.new(data["contact"]),
      version: data["version"]
    }
  end
end
