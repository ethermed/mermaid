defmodule MermaidParser.Flow do
  defstruct [:rows]
  alias MermaidParser.Flow
  alias MermaidParser.FlowRow
  alias MermaidParser.Node

  @type keyword_list :: [{atom, any}]

  @spec parse(String.t() | [keyword_list()]) :: {:ok, %Flow{} | :error, any}
  def parse(mermaid_string) when is_binary(mermaid_string) do
    case MermaidParser.flow(mermaid_string) do
      {:ok, rows, _, _, _, _} ->
        parse(rows)

      _ ->
        {:error, "Failed to parse flow"}
    end
  end

  def parse(rows) when is_list(rows) do
    desc_lookup = extract_node_descriptions(rows)

    flow_rows =
      rows
      |> Keyword.get_values(:row)
      |> Enum.map(fn row ->
        src = Keyword.get(row, :src)
        dest = Keyword.get(row, :dest)
        event = Keyword.get(row, :event) |> Enum.at(0)

        %FlowRow{
          src: enrich_node(src, desc_lookup),
          dest: enrich_node(dest, desc_lookup),
          event: event
        }
      end)

    {:ok, %Flow{rows: flow_rows}}
  end

  defp enrich_node(node, lookup) do
    id = Access.get(node, :id) |> Enum.at(0)
    desc = Map.get(lookup, id)
    %Node{id: id, desc: desc}
  end

  # In mermaid, you only have to include the description of a node once. After that, only
  # the id is needed. Just for simplicity, we'll include the description with every node.
  defp extract_node_descriptions(rows) do
    rows
    |> get_all_nodes()
    |> Enum.reduce(%{}, fn node, acc ->
      # if this node has a description, add it to the accumulator for later use
      id = Keyword.get(node, :id) |> Enum.at(0)
      desc = Keyword.get(node, :desc, []) |> Enum.at(0)

      case desc do
        nil -> acc
        _ -> Map.put(acc, id, desc)
      end
    end)
  end

  defp get_all_nodes(rows) do
    rows
    |> Keyword.get_values(:row)
    |> Enum.flat_map(fn row ->
      [
        Keyword.get(row, :src),
        Keyword.get(row, :dest)
      ]
    end)
  end
end
