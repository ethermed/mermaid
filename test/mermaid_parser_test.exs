defmodule MermaidParserTest do
  use ExUnit.Case
  doctest MermaidParser

#   describe "flowcharts" do
#     test "inline event flow" do
#       inline_flow = """
# flowchart TD
#     penguin -- wifi_ssh --> router
# """
#       assert MermaidParser.parse_flow(inline_flow) == {:ok, [line:
#         ["penguin", "wifi_ssh", "router"]
#       ]}
#     end
#   end
  describe "parse events" do
    [
      ["-- event -->", "event"],
      ["-- event string -->", "event string"],
      ["--event-->", "event"],
      ["--event string-->", "event string"],
      ["-->|event|", "event"],
      ["-->|event string|", "event string"],
      ["-->| event string |", "event string"],
    ]
    |> Enum.map(fn [input, output] ->
      @input input
      @output output
      test "parse |#{@input}| outputs |#{@output}|" do
        assert MermaidParser.parse_event(@input) == {:ok, @output}
      end
    end)
  end

  describe "parse steps" do
    [
      ["a", "a"],
      [" a", "a"],
      [" a ", "a"],
      ["test", "test"],
      [" test", "test"],
      [" test ", "test"],
      ["test[A long string]", {"test", "A long string"}],
      [" test{A long string}", {"test", "A long string"}],
      [" test<A long string>", {"test","A long string"}],
      [" test[ with spaces ]", {"test","with spaces"}],
      [" test[ with 123 ]", {"test","with 123"}],
      [" test[ with !-_ ]", {"test","with !-_"}],
    ]
    |> Enum.map(fn [input, output] ->
      @input input
      @output output
      @message (case output do
        output when is_tuple(output) ->
          "parse |#{input}| outputs |#{IO.inspect(Tuple.to_list(output))}|"
        _ ->
          "parse |#{input}| outputs |#{output}|"
      end)
      test @message do
        assert MermaidParser.parse_step(@input) == {:ok, @output}
      end
    end)
  end

  describe "parse labels" do
    [
      ["[A long string]", ["A long string"]],
      ["{A long string}", ["A long string"]],
      ["<A long string>", ["A long string"]],
      ["[ with spaces ]", ["with spaces"]],
      ["[ with 123 ]", ["with 123"]],
      ["[ with !-_ ]", ["with !-_"]],
    ]
    |> Enum.map(fn [input, output] ->
      @input input
      @output output

      test "parse |#{input}| outputs |#{output}|" do
        assert MermaidParser.parse_label(@input) == {:ok, @output}
      end
    end)

  end

  describe "parse sentence" do
    [
      ["A long string", ["A long string"]],
      [" with spaces ", ["with spaces"]],
      [" with 123 ", ["with 123"]],
      [" with !-_ ", ["with !-_"]],
    ]
    |> Enum.map(fn [input, output] ->
      @input input
      @output output

      test "parse |#{input}| outputs |#{output}|" do
        assert MermaidParser.parse_sentence(@input) == {:ok, @output}
      end
    end)

  end
end
