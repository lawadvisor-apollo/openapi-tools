defmodule OpenapiTools.RequestBuilderTest do
  use ExUnit.Case, async: true

  describe "request_all/2" do
    test "returns all entries" do
      query_fn = fn %{page: i} ->
        {:ok, %{total_pages: 100, entries: [i]}}
      end

      assert {:ok, list} = OpenapiTools.RequestBuilder.request_all(query_fn)
      assert is_list(list)
      assert 1 in list
      assert 50 in list
      assert 100 in list
    end

    test "returns error if first page fetch fails" do
      query_fn = fn %{page: 1} ->
        {:error, "first page failed"}
      end

      assert {:error, _reason} = OpenapiTools.RequestBuilder.request_all(query_fn)
    end

    test "returns error if any other page fetch fails" do
      query_fn = fn
        %{page: 55} ->
          {:error, "page 55 failed"}

        %{page: i} ->
          {:ok, %{total_pages: 100, entries: [i]}}
      end

      assert {:error, _reason} = OpenapiTools.RequestBuilder.request_all(query_fn)
    end

    test "returns all entries with mode arity_2" do
      query_fn = fn _atom_or_user, %{page: i} ->
        {:ok, %{total_pages: 100, entries: [i]}}
      end

      assert {:ok, list} =
               OpenapiTools.RequestBuilder.request_all(query_fn, %{},
                 query_mode: :arity_2,
                 first_arg: :test
               )

      assert is_list(list)
      assert 1 in list
      assert 50 in list
      assert 100 in list
    end
  end
end
