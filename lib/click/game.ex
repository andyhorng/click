defmodule Click.Game do
  use Ecto.Schema
  import Ecto.Changeset
  alias Click.Game


  schema "games" do
    field :name, :string
    field :state, :string

    timestamps()
  end

  @doc false
  def changeset(%Game{} = game, attrs) do
    game
    |> cast(attrs, [:name, :state])
    |> validate_required([:name, :state])
  end
end
