defmodule Hakkawine.Repo do
  use Ecto.Repo,
    otp_app: :hakkawine,
    adapter: Ecto.Adapters.Postgres
end
