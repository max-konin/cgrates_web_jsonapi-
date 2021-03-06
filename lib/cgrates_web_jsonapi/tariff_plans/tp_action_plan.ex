defmodule CgratesWebJsonapi.TariffPlans.TpActionPlan do
  use Ecto.Schema
  import Ecto.Changeset
  use EctoConditionals, repo: CgratesWebJsonapi.Repo
  @attributes ~w[tpid tag actions_tag timing_tag weight]a

  use CgratesWebJsonapi.CsvImport, module: __MODULE__, attributes: @attributes

  schema "tp_action_plans" do
    field :tpid, :string
    field :tag, :string
    field :actions_tag, :string
    field :timing_tag, :string
    field :weight, :decimal

    timestamps(
      inserted_at: :created_at,
      updated_at: false,
      inserted_at_source: :created_at,
      updated_at_source: false,
      type: :utc_datetime
    )

    has_many :tp_account_actions, CgratesWebJsonapi.TariffPlans.TpAccountAction,
      foreign_key: :action_plan_tag,
      references: :tag,
      on_delete: :delete_all
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @attributes)
    |> validate_required(@attributes)
    |> validate_length(:tag, max: 64)
    |> validate_length(:tpid, max: 64)
    |> validate_length(:actions_tag, max: 64)
    |> validate_length(:timing_tag, max: 64)
    |> unique_constraint(:tag, name: :tp_action_plans_tpid_tag_actions_tag_key)
  end
end
