alias Hakkawine.Repo

defmodule Hakkawine.DatabaseSeeder do
  def seed(schema, conflict_target, data_list, opts \\ []) do
    now = DateTime.utc_now()

    entries =
      Enum.map(data_list, fn item ->
        item
        |> Map.put_new(:created_at, now)
      end)

    on_conflict_strategy =
      case Keyword.get(opts, :update_fields) do
        nil -> :nothing
        fields when is_list(fields) -> {:replace, fields}
      end

    {count, _} =
      Repo.insert_all(
        schema,
        entries,
        on_conflict: on_conflict_strategy,
        conflict_target: conflict_target
      )

    IO.puts("  [Seeded] #{inspect(schema)}: Processed #{length(entries)} items (Rows affected: #{count})")
  end
end

seeds_dir = Path.join(__DIR__, "seeds")

seed_files = [
  "node_labels.exs",
  "obfs_domain.exs",
  "settings.exs",
  "user_audit_actions.exs",
]

IO.puts("\nStarting database seeding process...")

Enum.each(seed_files, fn file ->
  file_path = Path.join(seeds_dir, file)

  if File.exists?(file_path) do
    IO.puts("----------------------------------------")
    IO.puts("Loading seed file: priv/repo/seeds/#{file}")
    Code.require_file(file_path)
  else
    IO.puts("⚠️ Warning: Seed file not found -> #{file_path}")
  end
end)

IO.puts("\nAll seeding tasks completed successfully!\n")
