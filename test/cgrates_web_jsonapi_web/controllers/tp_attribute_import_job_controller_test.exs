defmodule CgratesWebJsonapi.TariffPlans.TpAttributeImportJobControllerTest do
  use CgratesWebJsonapi.ConnCase
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

  describe "POST create" do
    test "creates resource imported from csv file", %{conn: conn} do
      tariff_plan = insert(:tariff_plan)
      path = Path.expand("../fixtures/csv/tp-attributes.csv", __DIR__)
      csv = %Plug.Upload{path: path, filename: "tp-attributes.csv"}

      conn =
        post(conn, Routes.tp_attribute_import_job_path(conn, :create), %{
          "meta" => %{},
          "data" => %{
            "type" => "tp_attribute_import_job",
            "attributes" => %{"tpid" => tariff_plan.alias, "csv" => csv}
          }
        })
        |> doc()

      assert json_response(conn, 202)["data"]["id"]
    end
  end
end
