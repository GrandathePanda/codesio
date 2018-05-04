defmodule CodesioWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use CodesioWeb, :controller
      use CodesioWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  @supported_languages File.read!("assets/static/supported_languages.txt")
                       |> String.split("\n")
  def get_supported_languages() do
    @supported_languages
  end
  def controller do
    quote do
      use Phoenix.Controller, namespace: CodesioWeb
      import Plug.Conn
      import CodesioWeb.Router.Helpers
      import CodesioWeb.Gettext
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/codesio_web/templates",
                        namespace: CodesioWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1, get_flash: 1, action_name: 1, controller_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import CodesioWeb.Router.Helpers
      import CodesioWeb.ErrorHelpers
      import CodesioWeb.Gettext
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import CodesioWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
