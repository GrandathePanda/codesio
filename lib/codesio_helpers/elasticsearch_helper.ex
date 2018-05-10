defmodule CodesioHelpers.ElasticsearchHelper do
  @moduledoc """
    This module is a wrapper for elastix to create core elasticsearch functionality
    that this project will be using.
  """
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
    case status_code do
      200 ->  { :ok, body["suggest"]["snippet"] }
      _ -> { :error, body["error"] }
    end
  end
end


