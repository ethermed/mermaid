defmodule Mermaid.Flow do
  defstruct [:rows]
  alias Mermaid.Flow
  alias Mermaid.FlowRow
  alias Mermaid.Node

  @type t :: %__MODULE__{
          rows: [FlowRow.t()]
        }
  @type keyword_list :: [{atom, any}]

  @spec new([keyword_list()]) :: {:ok, Flow.t() | :error, any}
  def new(rows) when is_list(rows) do
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

    flow = %Flow{rows: flow_rows}

    case flow |> to_digraph() |> :digraph_utils.is_acyclic() do
      true -> {:ok, flow}
      false -> {:error, :not_acyclic}
    end
  end

  def to_digraph(%Flow{rows: rows}) do
    graph = :digraph.new()

    Enum.each(rows, fn %FlowRow{} = row ->
      ensure_vertex(graph, row.src.id, row.src.desc)
      ensure_vertex(graph, row.dest.id, row.dest.desc)
      :digraph.add_edge(graph, row.src.id, row.dest.id, row.event)
    end)

    graph
  end

  defp ensure_vertex(graph, id, label) do
    if :digraph.vertex(graph, id) == false, do: :digraph.add_vertex(graph, id, label)
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
