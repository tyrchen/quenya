defmodule Quenya do
  @moduledoc """
  Documentation for `Quenya`.
  """
  @version Quenya.MixProject.version()

  alias Quenya.CLI

  def main(argv) do
    case parse_args(argv) do
      {[cmd], %{args: args, flags: flags, options: options}} ->
        opts = Enum.into(Map.merge(flags, options), [])

        case cmd do
          :new -> CLI.New.run(args, opts)
          :build -> CLI.Build.run(args, opts)
        end

      _ ->
        IO.puts("You need to run a subcommand. See `quenya --help`.")
    end
  end

  defp parse_args(argv) do
    Optimus.new!(
      name: "quenya",
      description: "Manage quenya API apps",
      version: @version,
      author: "tyr.chen@gmail.com",
      about:
        "Quenya generates API code from your OpenAPI v3 spec. It aims to create pluggable, reusable and fun to play with API apps for you",
      allow_unknown_args: false,
      parse_double_dash: true,
      subcommands: [
        new: [
          name: "new",
          about: "Create a new Quenya APP",
          args: [
            file: [
              value_name: "SCHEMA_FILE",
              help: "OpenAPI v3 schema file to generate API app",
              required: true,
              parser: :string
            ],
            path: [
              value_name: "PATH",
              help: "destination path to generate API app",
              required: true,
              parser: :string
            ]
          ],
          flags: [
            install: [
              long: "--install",
              help: "Force to fetch and install dependencies"
            ],
            noinstall: [
              long: "--no-install",
              help: "Do not fetch or install dependencies"
            ],
            umbrella: [
              value_name: "UMBRELLA",
              short: "-u",
              long: "--umbrella",
              help: "Generate an umbrella project with an API app"
            ]
          ],
          options: [
            app: [
              value_name: "APP",
              short: "-a",
              long: "--app",
              help: "The name of the OTP application",
              required: false
            ],
            module: [
              value_name: "MODULE",
              short: "-m",
              long: "--module",
              help: "the name of the base module in the generated skeleton",
              required: false
            ]
          ]
        ],
        build: [
          name: "build",
          about: "rebuild source code based on OpenAPI v3 spec in an existing Quenya app"
        ]
      ]
    )
    |> Optimus.parse!(argv)
  end
end
