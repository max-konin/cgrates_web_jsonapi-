defmodule CgratesWebJsonapi.TariffPlans.TpDestinationRate do
  use Ecto.Schema
  import Ecto.Changeset
  use EctoConditionals, repo: CgratesWebJsonapi.Repo

  @attributes ~w[tpid tag destinations_tag rates_tag rounding_method rounding_decimals max_cost max_cost_strategy]a
  @required_attributes ~w[tpid tag destinations_tag rates_tag rounding_method rounding_decimals max_cost]a
  use CgratesWebJsonapi.CsvImport, module: __MODULE__, attributes: @attributes

  def rounding_methods, do: ["*up", "*down", "*middle"]
  def max_cost_strategies, do: ["*free", "*disconnect", ""]

  schema "tp_destination_rates" do
    field :tpid, :string
    field :tag, :string
    field :destinations_tag, :string
    field :rates_tag, :string
    field :rounding_method, :string
    field :rounding_decimals, :integer
    field :max_cost, :decimal, default: 0.0
    field :max_cost_strategy, :string, default: ""

    timestamps(
      inserted_at: :created_at,
      updated_at: false,
      inserted_at_source: :created_at,
      updated_at_source: false,
      type: :utc_datetime
    )

    has_many :tp_rating_plans, CgratesWebJsonapi.TariffPlans.TpRatingPlan,
      foreign_key: :destrates_tag,
      references: :tag,
      on_delete: :delete_all
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params |> maybe_assign_blank("max_cost_strategy"), @attributes)
    |> validate_required(@required_attributes)
    |> validate_length(:tag, max: 64)
    |> validate_length(:destinations_tag, max: 64)
    |> validate_length(:rates_tag, max: 64)
    |> validate_inclusion(:rounding_method, rounding_methods())
    |> validate_inclusion(:max_cost_strategy, max_cost_strategies())
    |> unique_constraint(:tag, name: :tp_destination_rates_tpid_tag_destinations_tag_key)
  end

  def maybe_assign_blank(struct, attr) do
    if is_nil(Map.get(struct, attr)) && is_nil(Map.get(struct, String.to_atom(attr))) do
      Map.merge(struct, %{attr => ""})
    else
      struct
    end
  end
end
