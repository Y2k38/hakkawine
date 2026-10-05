defmodule Hakkawine.Subscription.ProxyTemplate do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "proxy_templates" do
    field :name, :string
    field :code, :string
    field :scope, Ecto.Enum, values: [:client, :server]
    field :target, Ecto.Enum, values: [:general, :clash], default: :general
    field :format, :string
    field :content, :string
    field :is_active, :boolean

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at
    )
  end

  def changeset(proxy_templates, attrs) do
    proxy_templates
    |> cast(attrs, [:name, :code, :scope, :target, :format, :content, :is_active])
    |> validate_required([:name, :code, :scope, :target, :format, :content, :is_active])
    |> unique_constraint(:code, name: :uk_proxy_templates_code)
    |> unique_constraint([:scope, :target], name: :uk_proxy_templates_single_active)
  end
end
