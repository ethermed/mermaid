defmodule MermaidParser.GraphTest do
  use ExUnit.Case
  doctest MermaidParser.GraphValidator
  alias MermaidParser.GraphValidator

  describe "validate/1" do
    setup do
      data = [
        [
          row: [
            src: [id: "A", desc: "Start"],
            event: "empty",
            dest: [id: "B", desc: "Is the individual at average risk?"]
          ]
        ],
        [
          row: [
            src: [id: "B"],
            event: "Yes",
            dest: [id: "C", desc: "Is the individual 45 years old or older?"]
          ]
        ],
        [
          row: [
            src: [id: "B"],
            event: "No",
            dest: [id: "D", desc: "Does the individual meet any diagnostic criteria?"]
          ]
        ],
        [
          row: [
            src: [id: "C"],
            event: "Yes",
            dest: [id: "E", desc: "Screening CTC is indicated at 5-year intervals"]
          ]
        ],
        [
          row: [
            src: [id: "C"],
            event: "No",
            dest: [id: "F", desc: "Not Medically Necessary"]
          ]
        ],
        [
          row: [
            src: [id: "D"],
            event: "Yes good",
            dest: [id: "G", desc: "Diagnostic CTC is indicated"]
          ]
        ],
        [row: [src: [id: "D"], event: "No not really", dest: [id: "F"]]]
      ]

      {:ok, data: data}
    end

    test "adds all vertices", %{data: data} do
      graph = GraphValidator.to_digraph(data)
      vertices = :digraph.vertices(graph)

      expected_vertices = ["A", "B", "C", "D", "E", "F", "G"]
      assert Enum.sort(vertices) == Enum.sort(expected_vertices)
    end

    test "adds all edges with correct labels", %{data: data} do
      graph = GraphValidator.to_digraph(data)
      edges = :digraph.edges(graph)

      edges_with_labels =
        Enum.map(edges, fn edge ->
          {_, src, dest, label} = :digraph.edge(graph, edge)
          {src, dest, label}
        end)

      expected_edges_with_labels = [
        {"A", "B", "empty"},
        {"B", "C", "Yes"},
        {"B", "D", "No"},
        {"C", "E", "Yes"},
        {"C", "F", "No"},
        {"D", "G", "Yes good"},
        {"D", "F", "No not really"}
      ]

      assert Enum.sort(edges_with_labels) == Enum.sort(expected_edges_with_labels)
    end

    test "adds correct vertex attributes", %{data: data} do
      graph = GraphValidator.to_digraph(data)
      vertices = :digraph.vertices(graph)

      vertex_attributes =
        Enum.map(vertices, fn vertex ->
          :digraph.vertex(graph, vertex)
        end)

      expected_vertex_attributes = [
        {"A", "Start"},
        {"B", "Is the individual at average risk?"},
        {"C", "Is the individual 45 years old or older?"},
        {"D", "Does the individual meet any diagnostic criteria?"},
        {"E", "Screening CTC is indicated at 5-year intervals"},
        {"F", "Not Medically Necessary"},
        {"G", "Diagnostic CTC is indicated"}
      ]

      assert Enum.sort(vertex_attributes) == Enum.sort(expected_vertex_attributes)
    end
  end
end
