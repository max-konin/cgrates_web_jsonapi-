defmodule CgratesWebJsonapi.DeleteAll do
  defmacro __using__(_opts) do
    quote do
      use Phoenix.Controller
      alias CgratesWebJsonapi.Repo

      def delete_all(conn, params) do
        conn
        |> build_query(params)
        |> Repo.delete_all()

        send_resp(conn, :no_content, "")
      end
    end
  end
end
