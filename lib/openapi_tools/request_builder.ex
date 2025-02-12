defmodule OpenapiTools.RequestBuilder do
  defp build_request_opts(state, page) do
    cond do
      is_map(state.params) and state.build_params_mode == :string_map ->
        state.params
        |> Map.put("page", page)
        |> Map.put("limit", state.batch_size)

      is_map(state.params) and state.build_params_mode == :atom_map ->
        state.params
        |> Map.put(:page, page)
        |> Map.put(:limit, state.batch_size)

      is_list(state.params) ->
        Keyword.merge(state.params, page: page, limit: state.batch_size)

      state.params ->
        raise ArgumentError, "expected params to be a map or list, got #{inspect(state.params)}"
    end
  end

  defp perform_query(state, request_opts) do
    case state.query_mode do
      :arity_2 -> state.query_fn.(state.first_arg, request_opts)
      :arity_1 -> state.query_fn.(request_opts)
    end
  end

  defp fetch_first_page(state) do
    {body, error} =
      case perform_query(state, build_request_opts(state, 1)) do
        {:ok, struct} -> {struct, nil}
        {:error, error} -> {nil, error}
      end

    state
    |> Map.put(:first, body)
    |> Map.put(:error, error)
  end

  defp maybe_fetch_other_pages(%{error: nil, first: first} = state) when is_map(first) do
    total_pages = state.pageinfo_fn.(first).total_pages
    rem_page_count = total_pages - 1

    if rem_page_count <= 0 do
      Map.put(state, :others, [])
    else
      tasks =
        1..rem_page_count
        |> Task.async_stream(fn p ->
          perform_query(state, build_request_opts(state, p + 1))
        end)
        |> Enum.to_list()

      errors =
        Enum.filter(tasks, &(elem(&1, 0) == :error || elem(elem(&1, 1), 0) == :error))

      if errors == [] do
        Map.put(state, :others, Enum.map(tasks, &elem(elem(&1, 1), 1)))
      else
        Map.put(state, :error, errors)
      end
    end
  end

  defp maybe_fetch_other_pages(state) do
    Map.put(state, :others, [])
  end

  defp entries_from_result(state, result) do
    Map.get(result, state.entries_key)
  end

  # NOTE: Caveats:
  #       - does not fail fast if there's an error in the middle
  #         of the requests
  #       - unable to handle requests that doesn't start at page 1
  def request_all(query_fn, params \\ %{}, opts \\ []) do
    batch_size = Keyword.get(opts, :batch_size, 100)
    first_arg = Keyword.get(opts, :first_arg)
    build_params_mode = Keyword.get(opts, :build_params_mode, :atom_map)
    pageinfo_fn = Keyword.get(opts, :pageinfo, &Function.identity/1)
    entries_key = Keyword.get(opts, :entries_key, :entries)
    query_mode = Keyword.get(opts, :query_mode, :arity_1)

    %{
      query_fn: query_fn,
      params: params,
      batch_size: batch_size,
      first_arg: first_arg,
      build_params_mode: build_params_mode,
      pageinfo_fn: pageinfo_fn,
      entries_key: entries_key,
      query_mode: query_mode,
      error: nil
    }
    |> fetch_first_page()
    |> maybe_fetch_other_pages()
    |> case do
      %{error: error} when not is_nil(error) ->
        {:error, error}

      state ->
        {:ok,
         entries_from_result(state, state.first) ++
           Enum.flat_map(state.others, &entries_from_result(state, &1))}
    end
  end
end
