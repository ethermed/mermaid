defmodule Mermaid.ParserTest do
  use ExUnit.Case
  alias Mermaid.Parser

  doctest Mermaid.Parser

  @nodes [
    [" id ", [id: ["id"]]],
    ["  longer_id", [id: ["longer_id"]]],
    ["  id[hi]", [id: ["id"], desc: ["hi"]]],
    ["  id[HI]", [id: ["id"], desc: ["HI"]]],
    ["  id[HI there]", [id: ["id"], desc: ["HI there"]]],
    [~s(  id["HI there"]), [id: ["id"], desc: ["HI there"]]],
    [~s(  id["With ❤️ from #$%"]), [id: ["id"], desc: ["With ❤️ from #$%"]]],
    [
      ~s(  id["With ❤️ \n on the next line?"]),
      [id: ["id"], desc: ["With ❤️ \n on the next line?"]]
    ],
    [
      ~s(  B{Is the individual at average risk?}),
      [id: ["B"], desc: ["Is the individual at average risk?"]]
    ],
    [
      ~s(B ),
      [id: ["B"]]
    ]
  ]
  @events [
    [" --> ", [arc: ["empty"]]],
    ["-->", [arc: ["empty"]]],
    ["   -- event -->  ", [arc: ["event"]]],
    ["-- event string -->", [arc: ["event string"]]],
    ["--event-->", [arc: ["event"]]],
    ["--event string-->", [arc: ["event string"]]],
    ["-->|event|", [arc: ["event"]]],
    ["-->|event string|", [arc: ["event string"]]],
    ["-->| event string |", [arc: ["event string"]]]
  ]

  describe "nodes" do
    @nodes
    |> Enum.map(fn [input, output] ->
      @input input
      @output output
      test "parse |#{@input}| outputs |#{inspect(@output)}|" do
        assert Parser.parse_node(@input) == {:ok, @output, ""}
      end
    end)
  end

  describe "parse events" do
    @events
    |> Enum.map(fn [input, output] ->
      @input input
      @output output
      test "parse |#{@input}| outputs |#{inspect(@output)}|" do
        assert Parser.parse_event(@input) == {:ok, @output, ""}
      end
    end)
  end

  describe "lines" do
    test "all combinations" do
      Enum.each(@nodes, fn [src_inp, src_out] ->
        Enum.each(@events, fn [event_inp, event_out] ->
          Enum.each(@nodes, fn [dest_inp, dest_out] ->
            line = "#{src_inp} #{event_inp} #{dest_inp}"
            expected = [row: [source: src_out] ++ event_out ++ [target: dest_out]]
            assert Parser.parse_complete_line(line) == {:ok, expected, ""}
          end)
        end)
      end)
    end

    test "specific challenge" do
      line = "  B -->|Yes| C{Is the individual 45 years old or older?}"
      assert {:ok, _, ""} = Parser.parse_complete_line(line)
    end

    test "node only" do
      line = """
      flowchart TD
        Z1["Procedure Medically Necessary"]
      """

      expected_result = [node: [id: ["Z1"], desc: ["Procedure Medically Necessary"]]]
      assert {:ok, ^expected_result, "", _, _, _} = Parser.parse(line)
    end
  end

  describe "flowchart tag" do
    test "flowchart tag" do
      line = "flowchart TD"
      assert {:ok, [], "", _, _, _} = Parser.flowchart_header(line)
    end

    test "flowchart tag <newline>" do
      line = ~s(flowchart TD
      )
      assert {:ok, [], "      ", _, _, _} = Parser.flowchart_header(line)
    end
  end

  test "do it all" do
    flow = """
    flowchart TD
    A[Start] --> B{Is the individual at average risk?}
    B -->|Yes| C{Is the individual 45 years old or older?}
    B -->|No| D{Does the individual meet any diagnostic criteria?}
    C -->|Yes| E[Screening CTC is indicated at 5-year intervals]
    C -->|No| F[Not Medically Necessary]
    D -->|Yes good| G[Diagnostic CTC is indicated]
    D --No not really--> F
    """

    expected = [
      row: [
        source: [id: ["A"], desc: ["Start"]],
        arc: ["empty"],
        target: [id: ["B"], desc: ["Is the individual at average risk?"]]
      ],
      row: [
        source: [id: ["B"]],
        arc: ["Yes"],
        target: [id: ["C"], desc: ["Is the individual 45 years old or older?"]]
      ],
      row: [
        source: [id: ["B"]],
        arc: ["No"],
        target: [
          id: ["D"],
          desc: ["Does the individual meet any diagnostic criteria?"]
        ]
      ],
      row: [
        source: [id: ["C"]],
        arc: ["Yes"],
        target: [id: ["E"], desc: ["Screening CTC is indicated at 5-year intervals"]]
      ],
      row: [
        source: [id: ["C"]],
        arc: ["No"],
        target: [id: ["F"], desc: ["Not Medically Necessary"]]
      ],
      row: [
        source: [id: ["D"]],
        arc: ["Yes good"],
        target: [id: ["G"], desc: ["Diagnostic CTC is indicated"]]
      ],
      row: [source: [id: ["D"]], arc: ["No not really"], target: [id: ["F"]]]
    ]

    assert {:ok, ^expected, "", _, _, _} = Parser.parse(flow)
  end

  test "flow with node only lines" do
    flow = """
    flowchart TD
    A["A: Q"] -->|No| B["B: Q"]
    B -->|Yes| C["C: Q"]
    B -->|No| D
    D["D: Q"]
    """

    expected = [
      {:row,
       [
         source: [id: ["A"], desc: ["A: Q"]],
         arc: ["No"],
         target: [id: ["B"], desc: ["B: Q"]]
       ]},
      {:row,
       [
         source: [id: ["B"]],
         arc: ["Yes"],
         target: [id: ["C"], desc: ["C: Q"]]
       ]},
      {:row,
       [
         source: [id: ["B"]],
         arc: ["No"],
         target: [id: ["D"]]
       ]},
      node: [{:id, ["D"]}, {:desc, ["D: Q"]}]
    ]

    assert {:ok, ^expected, "", _, _, _} = Parser.parse(flow)
  end
end
