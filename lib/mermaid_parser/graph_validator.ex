defmodule MermaidParser.GraphValidator do
  alias MermaidParser.Flow
  alias MermaidParser.FlowRow

  @spec to_digraph( list() | %MermaidParser.Flow{} ) :: {:ok, :digraph.graph()} | {:error, String.t()}
  def validate(input) do
    graph = to_digraph(input)

    case is_acyclic(graph) do
      true ->
        case is_arborescence(graph) do
          true -> {:ok, graph}
          false -> {:error, "Graph is not an arborescence"}
        end

      false ->
        {:error, "Graph is not acyclic"}
    end
  end

  @spec to_digraph( list() | %MermaidParser.Flow{} ) :: :digraph.graph()
  def to_digraph(data) when is_list(data) do
    # Create a new digraph
    graph = :digraph.new()

    # Iterate over the rows and add vertices and edges
    Enum.each(data, fn row ->
      src_id = get_in(row, [:row, :src, :id])
      src_desc = get_in(row, [:row, :src, :desc])
      event = get_in(row, [:row, :event])
      dest_id = get_in(row, [:row, :dest, :id])
      dest_desc = get_in(row, [:row, :dest, :desc])

      # Add source and destination vertices

      ensure_vertex(graph, src_id, src_desc)
      ensure_vertex(graph, dest_id, dest_desc)

      # Add edge between source and destination
      :digraph.add_edge(graph, src_id, dest_id, event)
    end)

    graph
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

  def is_acyclic(graph), do: :digraph_utils.is_acyclic(graph)
  def is_arborescence(graph), do: :digraph_utils.is_arborescence(graph)
end
