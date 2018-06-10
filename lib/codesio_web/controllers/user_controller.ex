defmodule CodesioWeb.UserController do
  use CodesioWeb, :controller

  alias Codesio.Accounts
  alias Codesio.Accounts.User
  alias Codesio.SnippetsDisplay

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def show(conn, %{"username" => username}) do
    user = Accounts.get_user_by!(%{ username: username })
    user_snippets = SnippetsDisplay.snippets_for_user(user.id)
    render(conn, "show.html", user: user, user_snippets: user_snippets)
  end
end
