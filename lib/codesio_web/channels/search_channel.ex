defmodule CodesioWeb.SearchChannel do
  alias CodesioHelpers.ElasticsearchHelper
  alias Codesio.SnippetsDisplay
  alias Phoenix.View
  alias CodesioWeb.SnippetView
  alias CodesioWeb.Endpoint
  use Phoenix.Channel
  @paginate_params %{ "page_size" => 1, "page" => 1 }

  defp configure_pagination(%{"pagination_config" => config}) do
    @paginate_params
    |> Map.put("page", Map.get(config, "page", 1))
  end
  defp configure_pagination(_) do
    @paginate_params
  end
  def join("search:*", _message, socket) do
    {:ok, socket}
  end
  def handle_in("new_search", %{"body" => body} = params, socket) do
    {status, res} = load_search_results(body, params, socket.assigns[:user_id])
    resolve(status, "new_search", socket, Map.put(res, :endpoint, Endpoint))
  end
  def handle_in("continued_search", %{"body" => body, "pagination_config" => _ } = params, socket) do
    {status, res} = load_search_results(body, params, socket.assigns[:user_id])
    resolve(status, "continued_search", socket, Map.put(res, :endpoint, Endpoint))
  end
  def handle_in("continued_search", _, socket) do
    resolve(:error, "continued_search", socket, "Malformed request check that you provided the correct parameters to continued_search")
  end

  defp load_search_results("" = _, params, user_id) do
    SnippetsDisplay.paginate_snippets(configure_pagination(params), user_id)
  end
  defp load_search_results(body, params, user_id) do
    {status, body} = ElasticsearchHelper.search_tags(body)
    body = Enum.at(body, 0)
    config = configure_pagination(params)
    case status do
      :ok -> {status_, res} = load_snippets_from_es_results(body, config, user_id)
        case status_ do
          :ok ->{:ok, res}
          _ -> {:error, nil}
        end
      _ -> {:error, nil}
    end
  end

  defp load_snippets_from_es_results(results, config, user_id) do
    snippet_ids = results["options"]
                  |> Enum.map(fn hit ->
                    %{ "_source" => source } = hit
                    source
                  end)
                  |> Enum.map(fn source ->
                    %{ "id" => id } = source
                    id
                  end)
    SnippetsDisplay.paginate_batch_list(snippet_ids, config, user_id)
  end

  defp resolve(type, message_type, socket, m \\ nil)
  defp resolve(:ok, message_type, socket, assigns) when not is_nil(assigns) do
    html = View.render_to_string SnippetView, "snippets.html", assigns
    push socket, message_type, %{html: html}
    {:reply, :ok, socket}
  end
  defp resolve(:error, message_type, socket, message) do
    if not is_nil(message) do
      push socket, message_type, %{html: message}
    end
    {:reply, :errror, socket}
  end
end
