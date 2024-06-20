defmodule MermaidParserTest do
  use ExUnit.Case

  doctest MermaidParser

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
    ]
  ]
  @events [
    [" --> ", [event: ["empty"]]],
    ["-->", [event: ["empty"]]],
    ["   -- event -->  ", [event: ["event"]]],
    ["-- event string -->", [event: ["event string"]]],
    ["--event-->", [event: ["event"]]],
    ["--event string-->", [event: ["event string"]]],
    ["-->|event|", [event: ["event"]]],
    ["-->|event string|", [event: ["event string"]]],
    ["-->| event string |", [event: ["event string"]]]
  ]

  describe "nodes" do
    @nodes
    |> Enum.map(fn [input, output] ->
      @input input
      @output output
      test "parse |#{@input}| outputs |#{inspect(@output)}|" do
        assert MermaidParser.parse_node(@input) == {:ok, @output, ""}
      end
    end)
  end

  describe "parse events" do
    @events
    |> Enum.map(fn [input, output] ->
      @input input
      @output output
      test "parse |#{@input}| outputs |#{inspect(@output)}|" do
        assert MermaidParser.parse_event(@input) == {:ok, @output, ""}
      end
    end)
  end

  @tag :focus
  describe "lines" do
    test "all combinations" do
      Enum.each(@nodes, fn [src_inp, src_out] ->
        Enum.each(@events, fn [event_inp, event_out] ->
          Enum.each(@nodes, fn [dest_inp, dest_out] ->
            line = "#{src_inp} #{event_inp} #{dest_inp}"
            expected = [row: [src: src_out] ++ event_out ++ [dest: dest_out]]
            assert MermaidParser.parse_complete_line(line) == {:ok, expected, ""}
          end)
        end)
      end)
    end

    test "specific challenge" do
      line = "  B -->|Yes| C{Is the individual 45 years old or older?}"
      assert {:ok, _, ""} = MermaidParser.parse_complete_line(line)
    end
  end

  describe "flowchart tag" do
    test "flowchart tag" do
      line = "flowchart TD"
      assert {:ok, [], "", _, _, _} = MermaidParser.flowchart_header(line)
    end

    test "flowchart tag <newline>" do
      line = ~s(flowchart TD
      )
      assert {:ok, [], "      ", _, _, _} = MermaidParser.flowchart_header(line)
    end
  end

  @tag :focus
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
        src: [id: ["A"], desc: ["Start"]],
        event: ["empty"],
        dest: [id: ["B"], desc: ["Is the individual at average risk?"]]
      ],
      row: [
        src: [id: ["B"]],
        event: ["Yes"],
        dest: [id: ["C"], desc: ["Is the individual 45 years old or older?"]]
      ],
      row: [
        src: [id: ["B"]],
        event: ["No"],
        dest: [
          id: ["D"],
          desc: ["Does the individual meet any diagnostic criteria?"]
        ]
      ],
      row: [
        src: [id: ["C"]],
        event: ["Yes"],
        dest: [id: ["E"], desc: ["Screening CTC is indicated at 5-year intervals"]]
      ],
      row: [
        src: [id: ["C"]],
        event: ["No"],
        dest: [id: ["F"], desc: ["Not Medically Necessary"]]
      ],
      row: [
        src: [id: ["D"]],
        event: ["Yes good"],
        dest: [id: ["G"], desc: ["Diagnostic CTC is indicated"]]
      ],
      row: [src: [id: ["D"]], event: ["No not really"], dest: [id: ["F"]]]
    ]

    assert {:ok, ^expected, "", _, _, _} = MermaidParser.flow(flow)
    # assert false
  end
end
