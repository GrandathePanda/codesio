defmodule CodesioWeb.Router do
  use CodesioWeb, :router
  use Coherence.Router

  pipeline :always do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end
  pipeline :authorization do

  end
  pipeline :admin do
    plug CodesioHelpers.AuthorizationServices.Policies, :admin
  end

  pipeline :browser do
    plug Coherence.Authentication.Session
  end

  pipeline :protected do
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

  scope "/" do
    pipe_through :always
    pipe_through :browser
    coherence_routes()
  end

  scope "/" do
    pipe_through :always
    pipe_through :protected
    pipe_through :authorization
    coherence_routes :protected
  end

  scope "/", CodesioWeb do
    pipe_through :always
    pipe_through :protected
    pipe_through :authorization
    pipe_through :browser
    get "/users", UserController, :index
    get "/users/:username", UserController, :show
    resources "/snippets", SnippetController, except: [:index, :show]
  end

  scope "/", CodesioWeb do
    pipe_through :always
    pipe_through :browser # Use the default browser stack
    get "/", SnippetController, :index
    get "/snippets", SnippetController, :index
    get "/snippets/:id", SnippetController, :show
  end

  scope "/admin", CodesioWeb.Admin, as: :admin do
    pipe_through :always
    pipe_through :protected
    pipe_through :authorization
    pipe_through :admin
    resources "/snippets", SnippetController
    resources "/banned_ips", BannedIpController
  end

  # Other scopes may use custom stacks.
  # scope "/api", CodesioWeb do
  #   pipe_through :api
  # end
end
