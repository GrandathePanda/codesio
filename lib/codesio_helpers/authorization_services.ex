defmodule CodesioHelpers.AuthorizationServices do
  @moduledoc """
    This module serves to assist with functions related
    to route scope level authorization as well as any finer grained
    authoirzation.
  """

  defmodule Policies do
    use Phoenix.Controller
    use PolicyWonk.Policy
    use PolicyWonk.Enforce
    alias CodesioWeb.Router.Helpers, as: PathHelpers

    def policy(assigns, :admin) do
      current_user = assigns[:current_user]
      cond do
        is_nil(current_user) -> {:error, :admin}
        current_user.role == :superuser -> :ok
        true -> {:error, :admin}
      end
    end

    def policy(conn, {:is_snippet_owner, snippet_user_id}) do
      current_user_id = conn.assigns[:current_user].id
      case current_user_id == snippet_user_id do
        true -> :ok
        false -> {:error, :is_snippet_owner}
      end
    end

    def policy_error(conn, :admin) do
     conn
     |> put_flash(:error, "Not authorized.")
     |> redirect(to: PathHelpers.snippet_path(conn, :index))
    end

    def policy_error(conn, :is_snippet_owner) do
      conn
      |> put_flash(:error, "Not authorized.")
      |> redirect(to: PathHelpers.snippet_path(conn, :index))
    end

  end
end
