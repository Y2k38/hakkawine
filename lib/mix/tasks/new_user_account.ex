defmodule Mix.Tasks.NewUserAccount do
  use Mix.Task

  alias Hakkawine.Repo
  alias Hakkawine.Accounts.UserAccount

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    {opts, _args} =
      OptionParser.parse!(args,
        switches: [email: :string, role: :string],
        aliases: [e: :email, r: :role]
      )

    email = opts[:email]
    role = opts[:role]

    if is_nil(email) or is_nil(role) do
      Mix.raise("""
      Error: Missing required parameters!
      Usage: mix new_user_account --email <email> --role <role>
      Example: mix new_user_account -e admin@example.com -r system_admin
      """)
    end

    now = DateTime.utc_now()
    password = generate_complex_password()

    params = %{
      "account_type" => role,
      "status" => :active,
      "email" => email,
      "password" => password,
      "email_verified_at" => now,
      "password_updated_at" => now,
    }

    changeset = UserAccount.changeset(%UserAccount{}, params)

    case Repo.insert(changeset) do
      {:ok, user_account} ->
        Mix.shell().info("""
        ✅ User created successfully!

        Account/Email  : #{user_account.email}
        Role           : #{user_account.account_type}
        Random Password: #{password}

        ⚠️ Please keep the initial password safe!
        """)

      {:error, changeset} ->
        errors = format_errors(changeset)
        Mix.shell().error("❌ Failed to create user:\n#{errors}")
    end
  end

  defp generate_complex_password() do
    length    = 16
    uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.graphemes()
    lowercase = "abcdefghijklmnopqrstuvwxyz" |> String.graphemes()
    numbers   = "0163456789" |> String.graphemes()
    symbols   = "!@#$%^&*()_+-=[]{}|;:,.<>?" |> String.graphemes()

    required_chars = [
      Enum.random(uppercase),
      Enum.random(lowercase),
      Enum.random(numbers),
      Enum.random(symbols)
    ]

    all_chars = uppercase ++ lowercase ++ numbers ++ symbols
    remaining_length = length - length(required_chars)
    remaining_chars = Enum.map(1..remaining_length, fn _ -> Enum.random(all_chars) end)

    (required_chars ++ remaining_chars)
    |> Enum.shuffle()
    |> Enum.join()
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
    |> Enum.map(fn {field, errs} -> "  - #{field}: #{Enum.join(errs, ", ")}" end)
    |> Enum.join("\n")
  end
end
