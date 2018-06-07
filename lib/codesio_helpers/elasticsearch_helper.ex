defmodule CodesioHelpers.ElasticsearchHelper do
  @moduledoc """
    This module is a wrapper for elastix to create core elasticsearch functionality
    that this project will be using.
  """
  require Logger
  @host Application.get_env(:elastix, :host)
  def create_indices() do
    Elastix.Index.create(Application.get_env(:elastix, :host), "snippets", %{})
    mapping = %{
          properties: %{
            tags: %{ type: "text" },
            language: %{ type: "text" },
            id: %{ type: "integer" },
            snippet_suggest: %{ type: "completion" }
          }
    }
    Elastix.Mapping.put(Application.get_env(:elastix, :host), "snippets", "snippet", mapping)
  end

  def insert_into(%{ "tags" => tags} = data) do
    query_fields = Map.put(data, "snippet_suggest", tags)
    Elastix.Document.index_new(@host, "snippets", "snippet", query_fields)
  end

  def search_tags(search) do
    query = %{
      suggest: %{
        snippet: %{
          text: search,
          completion: %{
            field: "snippet_suggest"
          }
        }
      }}
    { _, res} = Elastix.Search.search(@host, "snippets", ["snippet"], query)
    %HTTPoison.Response{body: body, status_code: status_code} = res
    ids = case body["suggest"]["snippet"] do
      nil -> []
      _ -> get_snippet_ids(Enum.at(body["suggest"]["snippet"], 0))
    end
    case status_code do
      200 ->  {:ok, ids}
      _ -> Logger.error(body["error"])
        {:error, body["error"]}
    end
  end

  defp get_snippet_ids(results) do
    results["options"]
    |> Enum.map(fn hit ->
      %{ "_source" => source } = hit
      source
    end)
    |> Enum.map(fn source ->
      %{ "id" => id } = source
      id
    end)
  end
end


