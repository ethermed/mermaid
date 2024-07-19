defmodule MermaidTest do
  use ExUnit.Case
  import Assertions
  doctest Mermaid
  alias Mermaid

  test "parse/1" do
    mermaid_flow = """
    flowchart TD
      A[Start] --> B{Is the individual at average risk?}
      B -->|Yes| C{Is the individual 45 years old or older?}
      B -->|No| D{Does the individual meet any diagnostic criteria?}
      C -->|Yes| E[Screening CTC is indicated at 5-year intervals]
      C -->|No| F[Not Medically Necessary]
      D -->|Yes good| G[Diagnostic CTC is indicated]
      D --No not really--> F
    """

    flow = [
      %{
        source: %{id: "A", desc: "Start"},
        arc: "empty",
        target: %{id: "B", desc: "Is the individual at average risk?"}
      },
      %{
        source: %{id: "B", desc: "Is the individual at average risk?"},
        arc: "Yes",
        target: %{id: "C", desc: "Is the individual 45 years old or older?"}
      },
      %{
        source: %{id: "B", desc: "Is the individual at average risk?"},
        arc: "No",
        target: %{id: "D", desc: "Does the individual meet any diagnostic criteria?"}
      },
      %{
        source: %{id: "C", desc: "Is the individual 45 years old or older?"},
        arc: "Yes",
        target: %{id: "E", desc: "Screening CTC is indicated at 5-year intervals"}
      },
      %{
        source: %{id: "C", desc: "Is the individual 45 years old or older?"},
        arc: "No",
        target: %{id: "F", desc: "Not Medically Necessary"}
      },
      %{
        source: %{id: "D", desc: "Does the individual meet any diagnostic criteria?"},
        arc: "Yes good",
        target: %{id: "G", desc: "Diagnostic CTC is indicated"}
      },
      %{
        source: %{id: "D", desc: "Does the individual meet any diagnostic criteria?"},
        arc: "No not really",
        target: %{id: "F", desc: "Not Medically Necessary"}
      }
    ]

    {:ok, actual_flow} = Mermaid.parse(mermaid_flow)

    Enum.each(flow, fn expected_step ->
      assert_map_in_list(expected_step, actual_flow, ~w(source arc target)a)
    end)

    # assert {:ok, flow} == Mermaid.parse(mermaid_flow)
  end
end
