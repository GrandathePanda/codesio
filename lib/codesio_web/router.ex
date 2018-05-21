defmodule CodesioWeb.Router do
  use CodesioWeb, :router
  use Coherence.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true
    plug :put_user_token
  end
  defp put_user_token(conn, _) do
    if current_user = conn.assigns[:current_user] do
      token = Phoenix.Token.sign(conn, "user socket", current_user.id)
      assign(conn, :user_token, token)
    else
      conn
    end
  end
  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :browser
    coherence_routes()
  end

  scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end

  scope "/", CodesioWeb do
    pipe_through :browser # Use the default browser stack
    get "/", SnippetController, :index
    get "/snippets", SnippetController, :index
  end

  scope "/", CodesioWeb do
    pipe_through :protected
    get "/users", UserController, :index
    get "/users/show", UserController, :show
    resources "/snippets", SnippetController, except: [:index]
  end

  # Other scopes may use custom stacks.
  # scope "/api", CodesioWeb do
  #   pipe_through :api
  # end
end
