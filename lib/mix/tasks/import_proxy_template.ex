defmodule Mix.Tasks.ImportProxyTemplate do
  use Mix.Task

  alias Hakkawine.Repo
  alias Hakkawine.Utils
  alias Hakkawine.Subscription.ProxyTemplate

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    {opts, _args} =
      OptionParser.parse!(args,
        switches: [
          name: :string,
          code: :string,
          scope: :string,
          target: :string,
          file_path: :string
        ],
        aliases: [
          n: :name,
          c: :code,
          s: :scope,
          t: :target,
          f: :file_path
        ]
      )

    IO.inspect(opts, label: ">>> opts")

    unless opts[:name] && opts[:code] && opts[:scope] && opts[:target] && opts[:file_path] do
      Mix.raise("""
      Error: Missing required parameters!
      Example: mix import_proxy_template --name 'Clash' --code 'clash-v1' --scope client --target clash --file_path ./tpl.yaml
      """)
    end

    format =
      case Path.extname(opts[:file_path]) do
        ext when ext in [".yaml", ".yml"] -> "yaml"
        "." <> ext when ext != "" -> ext
        _ -> "yaml"
      end

    params = %{
      "name" => opts[:name],
      "code" => opts[:code],
      "scope" => opts[:scope],
      "target" => opts[:target],
      "format" => format,
      "content" => File.read!(opts[:file_path]),
      "is_active" => true
    }

    %ProxyTemplate{}
    |> ProxyTemplate.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, t} ->
        Mix.shell().info("✅ Successfully imported [ID: #{t.id}] #{t.name}")

      {:error, cs} ->
        Mix.shell().error("❌ Failed to write to database:\n#{Utils.format_changeset_errors(cs)}")
    end
  end
end
