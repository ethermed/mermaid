defmodule Mermaid do
  @moduledoc """
  n the context of directed graphs, the terms used to describe the elements and relationships are quite specific:

  1.	Node (or Vertex): The fundamental unit of a graph. For example, Node 1 and Node 2 are vertices in the graph.
  2.	Arc (or Directed Edge): The directed connection from one node to another. An arc has a direction, indicating the flow from a starting node (source) to an ending node (target).
  3.	Source (or Tail): The starting node of a directed edge. For an arc connecting Node 1 to Node 2, Node 1 is the source.
  4.	Target (or Head): The ending node of a directed edge. For an arc connecting Node 1 to Node 2, Node 2 is the target.
  5.	Incident From: A term used to describe an edge that originates from a node. For instance, the arc is incident from Node 1.
  6.	Incident To: A term used to describe an edge that points to a node. For instance, the arc is incident to Node 2.

  So, for a directed edge that connects Node 1 to Node 2, you can say:

  •	Node 1 is the source (or tail).
  •	Node 2 is the target (or head).
  •	The arc (or directed edge) connects Node 1 to Node 2.
  """
  alias Mermaid.Parser
  require Logger

  @type src_arc_target :: %{
          source_id: String.t(),
          source_desc: String.t(),
          arc: String.t(),
          target_id: String.t(),
          target_desc: String.t()
        }
  @spec parse(String.t()) :: {:ok, [src_arc_target()]} | {:error, atom()}
  def parse(mermaid_string) do
    case Parser.parse(mermaid_string) do
      {:ok, src_arc_targets, _, _, _, _} ->
        clean(src_arc_targets)

      err ->
        Logger.critical("Error parsing mermaid string: #{inspect(err)}")
        {:error, :mermaid_parse_error}
    end
  end

  defp clean(src_arc_targets) when is_list(src_arc_targets) do
    desc_lookup = extract_node_descriptions(src_arc_targets)

    src_arc_targets =
      src_arc_targets
      |> Keyword.get_values(:row)
      |> Enum.map(fn row ->
        arc = Keyword.get(row, :arc) |> Enum.at(0)

        source = Keyword.get(row, :source)
        source_id = Access.get(source, :id) |> Enum.at(0)
        source_desc = Map.get(desc_lookup, source_id)

        target = Keyword.get(row, :target)
        target_id = Access.get(target, :id) |> Enum.at(0)
        target_desc = Map.get(desc_lookup, target_id)

        %{
          source_id: source_id,
          source_desc: source_desc,
          target_id: target_id,
          target_desc: target_desc,
          arc: arc
        }
      end)

    case is_acyclic(src_arc_targets) do
      true -> {:ok, src_arc_targets}
      false -> {:error, :not_acyclic}
    end
  end

  defp is_acyclic(src_arc_targets) do
    src_arc_targets
    |> to_digraph()
    |> :digraph_utils.is_acyclic()
  end

  def to_digraph(rows) do
    graph = :digraph.new()

    Enum.each(rows, fn %{} = row ->
      ensure_vertex(graph, row.source_id, row.source_desc)
      ensure_vertex(graph, row.target_id, row.target_desc)
      :digraph.add_edge(graph, row.source_id, row.target_id, row.arc)
    end)

    graph
  end

  defp ensure_vertex(graph, id, label) do
    if :digraph.vertex(graph, id) == false, do: :digraph.add_vertex(graph, id, label)
  end

  # defp enrich_node(node, lookup) do
  #   id = Access.get(node, :id) |> Enum.at(0)
  #   desc = Map.get(lookup, id)
  #   %{id: id, desc: desc}
  # end

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
        Keyword.get(row, :source),
        Keyword.get(row, :target)
      ]
    end)
  end
end
