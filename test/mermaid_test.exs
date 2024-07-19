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
        source_id: "A",
        source_desc: "Start",
        arc: "empty",
        target_id: "B",
        target_desc: "Is the individual at average risk?"
      },
      %{
        source_id: "B",
        source_desc: "Is the individual at average risk?",
        arc: "Yes",
        target_id: "C",
        target_desc: "Is the individual 45 years old or older?"
      },
      %{
        source_id: "B",
        source_desc: "Is the individual at average risk?",
        arc: "No",
        target_id: "D",
        target_desc: "Does the individual meet any diagnostic criteria?"
      },
      %{
        source_id: "C",
        source_desc: "Is the individual 45 years old or older?",
        arc: "Yes",
        target_id: "E",
        target_desc: "Screening CTC is indicated at 5-year intervals"
      },
      %{
        source_id: "C",
        source_desc: "Is the individual 45 years old or older?",
        arc: "No",
        target_id: "F",
        target_desc: "Not Medically Necessary"
      },
      %{
        source_id: "D",
        source_desc: "Does the individual meet any diagnostic criteria?",
        arc: "Yes good",
        target_id: "G",
        target_desc: "Diagnostic CTC is indicated"
      },
      %{
        source_id: "D",
        source_desc: "Does the individual meet any diagnostic criteria?",
        arc: "No not really",
        target_id: "F",
        target_desc: "Not Medically Necessary"
      }
    ]

    {:ok, actual_flow} = Mermaid.parse(mermaid_flow)

    Enum.each(flow, fn expected_step ->
      assert_map_in_list(
        expected_step,
        actual_flow,
        ~w(source_id source_desc arc target_id target_desc)a
      )
    end)

    # assert {:ok, flow} == Mermaid.parse(mermaid_flow)
  end
end
