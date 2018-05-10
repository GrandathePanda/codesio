defmodule CodesioWeb.SearchChannel do
  alias CodesioHelpers.ElasticsearchHelper
  alias Codesio.SnippetsDisplay
  alias Phoenix.View
  alias CodesioWeb.SnippetView
  alias CodesioWeb.Endpoint
  use Phoenix.Channel

  def join("search:*", _message, socket) do
    {:ok, socket}
  end
  def handle_in("new_search", %{"body" => ""}, socket) do
    snippets = SnippetsDisplay.list_snippets()
    html = View.render_to_string SnippetView, "snippets.html", snippets: snippets, endpoint: Endpoint
    push socket, "new_search", %{html: html}
    {:reply, :ok, socket}
  end
  def handle_in("new_search", %{"body" => body}, socket) do
    {status, body} = ElasticsearchHelper.search_tags(body)
    body = Enum.at(body, 0)
    case status do
      :ok ->
        snippet_ids = body["options"]
                   |> Enum.map(fn hit ->
                     %{ "_source" => source } = hit
                     source
                   end)
                   |> Enum.map(fn source ->
                     %{ "id" => id } = source
                     id
                   end)
        snippets = SnippetsDisplay.batch_list(snippet_ids)
        html = View.render_to_string SnippetView, "snippets.html", snippets: snippets, endpoint: Endpoint
        push socket, "new_search", %{html: html}
        {:reply, :ok, socket}
      _ -> {:reply, :error, socket}
    end
  end
end
