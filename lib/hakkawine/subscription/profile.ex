defmodule Hakkawine.Subscription.Profile do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field :content, :string
    field :type, :string, default: "application/yaml"
    field :filename, :string, default: "config.yaml"
    field :title, :string
    field :etag, :string
    field :interval, :integer, default: 24
  end

  def new(attrs) do
    struct!(__MODULE__, attrs)
  end
end
