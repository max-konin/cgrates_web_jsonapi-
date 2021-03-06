defmodule CgratesWebJsonapi.TariffPlans.TpActionPlanControllerTest do
  use CgratesWebJsonapi.ConnCase

  alias CgratesWebJsonapi.TariffPlans.TpActionPlan
  alias CgratesWebJsonapi.Repo

  import CgratesWebJsonapi.Factory
  import CgratesWebJsonapi.Guardian

  setup do
    user = insert(:user)

    {:ok, token, _} = encode_and_sign(user, %{}, token_type: :access)

    conn =
      build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")
      |> put_req_header("authorization", "bearer: " <> token)

    {:ok, conn: conn}
  end

  describe "GET index" do
    test "lists all entries related tariff plan on index", %{conn: conn} do
      tariff_plan_1 = insert(:tariff_plan)
      tariff_plan_2 = insert(:tariff_plan)

      insert(:tp_action_plan, tpid: tariff_plan_1.alias)
      insert(:tp_action_plan, tpid: tariff_plan_2.alias)

      conn = get(conn, Routes.tp_action_plan_path(conn, :index, tpid: tariff_plan_1.alias)) |> doc
      assert length(json_response(conn, 200)["data"]) == 1
    end

    test "filtering by tag", %{conn: conn} do
      tariff_plan = insert(:tariff_plan)

      t1 = insert(:tp_action_plan, tpid: tariff_plan.alias, tag: "A")
      insert(:tp_action_plan, tpid: tariff_plan.alias, tag: "B")

      conn =
        get(conn, Routes.tp_action_plan_path(conn, :index, tpid: tariff_plan.alias),
          filter: %{tag: t1.tag}
        )
        |> doc

      assert length(json_response(conn, 200)["data"]) == 1
    end

    test "filtering by actions_tag", %{conn: conn} do
      tariff_plan = insert(:tariff_plan)

      t1 = insert(:tp_action_plan, tpid: tariff_plan.alias, actions_tag: "a")
      insert(:tp_action_plan, tpid: tariff_plan.alias, actions_tag: "b")

      conn =
        get(conn, Routes.tp_action_plan_path(conn, :index, tpid: tariff_plan.alias),
          filter: %{actions_tag: t1.actions_tag}
        )
        |> doc

      assert length(json_response(conn, 200)["data"]) == 1
    end

    test "filtering by timing_tag", %{conn: conn} do
      tariff_plan = insert(:tariff_plan)

      t1 = insert(:tp_action_plan, tpid: tariff_plan.alias)
      insert(:tp_action_plan, tpid: tariff_plan.alias)

      conn =
        get(conn, Routes.tp_action_plan_path(conn, :index, tpid: tariff_plan.alias),
          filter: %{timing_tag: t1.timing_tag}
        )
        |> doc

      assert length(json_response(conn, 200)["data"]) == 1
    end

    test "filtering by weight", %{conn: conn} do
      tariff_plan = insert(:tariff_plan)

      t1 = insert(:tp_action_plan, tpid: tariff_plan.alias, weight: 1)
      insert(:tp_action_plan, tpid: tariff_plan.alias, weight: 2)

      conn =
        get(conn, Routes.tp_action_plan_path(conn, :index, tpid: tariff_plan.alias),
          filter: %{weight: t1.weight}
        )
        |> doc

      assert length(json_response(conn, 200)["data"]) == 1
    end
  end

  describe "GET show" do
    test "shows chosen resource", %{conn: conn} do
      tariff_plan = insert(:tariff_plan)
      tp_action_plan = insert(:tp_action_plan, tpid: tariff_plan.alias)

      conn = get(conn, Routes.tp_action_plan_path(conn, :show, tp_action_plan)) |> doc
      data = json_response(conn, 200)["data"]
      assert data["id"] == "#{tp_action_plan.id}"
      assert data["type"] == "tp-action-plan"
      assert data["attributes"]["tpid"] == tp_action_plan.tpid
      assert data["attributes"]["tag"] == tp_action_plan.tag
      assert data["attributes"]["actions-tag"] == tp_action_plan.actions_tag
      assert data["attributes"]["timing-tag"] == tp_action_plan.timing_tag
      assert data["attributes"]["weight"] == "10.00"
    end

    test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
      assert_error_sent 404, fn ->
        get(conn, Routes.tp_action_plan_path(conn, :show, -1)) |> doc()
      end
    end
  end

  describe "GET export_to_csv" do
    test "returns status 'ok'", %{conn: conn} do
      tariff_plan = insert(:tariff_plan)
      insert(:tp_action_plan, tpid: tariff_plan.alias, actions_tag: "at1", timing_tag: "t1")
      insert(:tp_action_plan, tpid: tariff_plan.alias, actions_tag: "at2")

      conn =
        conn
        |> get(Routes.tp_action_plan_path(conn, :export_to_csv), %{
          tpid: tariff_plan.alias,
          filter: %{actions_tag: "at1", timing_tag: "t1"}
        })
        |> doc()

      assert conn.status == 200
    end
  end

  describe "POST create" do
    test "creates and renders resource when data is valid", %{conn: conn} do
      tariff_plan = insert(:tariff_plan)
      params = Map.merge(params_for(:tp_action_plan), %{tpid: tariff_plan.alias})

      conn =
        post(conn, Routes.tp_action_plan_path(conn, :create), %{
          "meta" => %{},
          "data" => %{
            "type" => "tp_action_plan",
            "attributes" => params
          }
        })
        |> doc()

      assert json_response(conn, 201)["data"]["id"]
      assert Repo.get_by(TpActionPlan, params)
    end

    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.tp_action_plan_path(conn, :create), %{
          "meta" => %{},
          "data" => %{
            "type" => "tp_action_plan",
            "attributes" => %{tag: nil}
          }
        })
        |> doc()

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "PATCH/PUT update" do
    test "updates and renders chosen resource when data is valid", %{conn: conn} do
      tariff_plan = insert(:tariff_plan)
      tp_action_plan = insert(:tp_action_plan, tpid: tariff_plan.alias)
      params = params_for(:tp_action_plan)

      conn =
        put(conn, Routes.tp_action_plan_path(conn, :update, tp_action_plan), %{
          "meta" => %{},
          "data" => %{
            "type" => "tp_action_plan",
            "id" => tp_action_plan.id,
            "attributes" => params
          }
        })
        |> doc()

      assert json_response(conn, 200)["data"]["id"]
      assert Repo.get_by(TpActionPlan, params)
    end

    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
      tariff_plan = insert(:tariff_plan)
      tp_action_plan = insert(:tp_action_plan, tpid: tariff_plan.alias)

      conn =
        put(conn, Routes.tp_action_plan_path(conn, :update, tp_action_plan), %{
          "meta" => %{},
          "data" => %{
            "type" => "tp_action_plan",
            "id" => tp_action_plan.id,
            "attributes" => %{tag: nil}
          }
        })
        |> doc

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "DELETE destroy" do
    test "deletes chosen resource", %{conn: conn} do
      tariff_plan = insert(:tariff_plan)
      tp_action_plan = insert(:tp_action_plan, tpid: tariff_plan.alias)

      conn = delete(conn, Routes.tp_action_plan_path(conn, :delete, tp_action_plan)) |> doc
      assert response(conn, 204)
      refute Repo.get(TpActionPlan, tp_action_plan.id)
    end
  end

  describe "DELETE delete_all" do
    test "deletes all records by filter", %{conn: conn} do
      tariff_plan = insert(:tariff_plan)

      tp_action_plan1 =
        insert(:tp_action_plan, tpid: tariff_plan.alias, actions_tag: "at1", timing_tag: "t1")

      tp_action_plan2 = insert(:tp_action_plan, tpid: tariff_plan.alias, actions_tag: "at2")

      conn =
        conn
        |> post(Routes.tp_action_plan_path(conn, :delete_all), %{
          tpid: tariff_plan.alias,
          filter: %{actions_tag: "at1", timing_tag: "t1"}
        })

      assert Repo.get(TpActionPlan, tp_action_plan2.id)
      refute Repo.get(TpActionPlan, tp_action_plan1.id)
    end
  end
end
