defmodule CodesioWeb.LayoutView do
  use CodesioWeb, :view
  def conditional_classes_for_body(conn, view_template) do
    case js_view_name(conn, view_template) do
      "SnippetNewView" -> "purple darken-2"
      "SnippetShowView" -> "purple darken-2"
      "SnippetEditView" -> "purple darken-2"
      _ -> ""
    end
  end
  def js_view_name(conn, view_template) do
    [view_name(conn), template_name(view_template)]
    |> Enum.reverse
    |> List.insert_at(0, "view")
    |> Enum.map(&String.capitalize/1)
    |> Enum.reverse
    |> Enum.join("")
  end
  defp view_name(conn) do
    conn
    |> view_module
    |> Phoenix.Naming.resource_name
    |> String.replace("_view", "")
  end
  defp template_name(template) when is_binary(template) do
    template
    |> String.split(".")
    |> Enum.at(0)
  end
end
