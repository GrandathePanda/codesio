defmodule CodesioWeb.SearchChannel do
  alias CodesioHelpers.ElasticsearchHelper
  alias Codesio.SnippetsDisplay
  alias Phoenix.View
  alias CodesioWeb.SnippetView
  alias CodesioWeb.Endpoint
  use Phoenix.Channel
  @paginate_params %{ "page_size" => 1 }
  def join("search:*", _message, socket) do
    {:ok, socket}
  end
  def handle_in("new_search", %{"body" => ""}, socket) do
    {status, res} = SnippetsDisplay.paginate_snippets(@paginate_params, socket.assigns)
    case status do
      :ok -> render_results(socket, Map.put(res, :endpoint, Endpoint))
        {:reply, :ok, socket}
      :error -> {:reply, :error, socket}
    end
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
        {status_, res} = SnippetsDisplay.paginate_batch_list(snippet_ids, @paginate_params, socket.assigns[:user_id])
        case status_ do
          :ok -> render_results(socket, Map.put(res, :endpoint, Endpoint))
            {:reply, :ok, socket}
          _ -> {:reply, :error, socket}
        end
      _ -> {:reply, :error, socket}
    end
  end

  def render_results(socket, assigns) do
    html = View.render_to_string SnippetView, "snippets.html", assigns
    push socket, "new_search", %{html: html}
  end
end
