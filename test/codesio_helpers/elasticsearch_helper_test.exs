defmodule CodesioHelpers.ElasticsearchHelperTest do
  use CodesioWeb.ConnCase, async: false
  alias CodesioHelpers.ElasticsearchHelper
  import Elastix

  @test_snippet %{ snippet: "def hi() do\n\tIO.puts('hi')\nend", tags: ["elixir", "hello", "z"], language: "elixir", id: 1 }
  @host Application.get_env(:elastix, :host)
  setup do
      ElasticsearchHelper.create_indices()
    on_exit fn ->
      Elastix.Index.delete(@host, "snippets")
    end
  end
  describe "index creation" do
    test "snippets index is available with mapping" do
      {_, exists} = Elastix.Index.exists?(@host, "snippets")
      {_, %HTTPoison.Response{body: body}} = Elastix.Mapping.get(@host, "snippets", "snippet")
      mapping = body["snippets"]["mappings"]["snippet"]["properties"]
      assert exists == true
      assert mapping["tags"]["type"] == "text"
      assert mapping["language"]["type"] == "text"
      assert mapping["id"]["type"] == "integer"
    end
  end

  describe "document operations on an index" do
    test "creating new document" do
      ElasticsearchHelper.insert_into(@test_snippet)
      :timer.sleep(1000)
      query = %{ query: %{
        match: %{
          tags: %{
            query: "elixir hello world example"
          }
        }
      }}
      {_, %HTTPoison.Response{ body: body, status_code: status}} = Elastix.Search.search(@host, "snippets", ["snippet"], query)
      assert status == 200
      assert body["hits"]["hits"] != []
    end

    test "deleting a document" do
      ElasticsearchHelper.insert_into(@test_snippet)

    end

    test "search a document based on tags" do
      ElasticsearchHelper.insert_into(@test_snippet)
      :timer.sleep(1000)
      { _, hits } = ElasticsearchHelper.search_tags("elixir hello world example ")
      assert hits != []
    end
  end
end
