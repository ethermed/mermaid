defmodule MermaidParser.FlowTest do
	use ExUnit.Case
	doctest MermaidParser.Flow
	alias MermaidParser.Flow
  alias MermaidParser.FlowRow
  alias MermaidParser.Node

  test "parse_all" do
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

    flow = %Flow{
      rows: [
        %FlowRow{
          src: %Node{id: "A", desc: "Start"},
          event: "empty",
          dest: %Node{id: "B", desc: "Is the individual at average risk?"}
        },
        %FlowRow{
          src: %Node{id: "B", desc: "Is the individual at average risk?"},
          event: "Yes",
          dest: %Node{id: "C", desc: "Is the individual 45 years old or older?"}
        },
        %FlowRow{
          src: %Node{id: "B", desc: "Is the individual at average risk?"},
          event: "No",
          dest: %Node{id: "D", desc: "Does the individual meet any diagnostic criteria?"}
        },
        %FlowRow{
          src: %Node{id: "C", desc: "Is the individual 45 years old or older?"},
          event: "Yes",
          dest: %Node{id: "E", desc: "Screening CTC is indicated at 5-year intervals"}
        },
        %FlowRow{
          src: %Node{id: "C", desc: "Is the individual 45 years old or older?"},
          event: "No",
          dest: %Node{id: "F", desc: "Not Medically Necessary"}
        },
        %FlowRow{
          src: %Node{id: "D", desc: "Does the individual meet any diagnostic criteria?"},
          event: "Yes good",
          dest: %Node{id: "G", desc: "Diagnostic CTC is indicated"}
        },
        %FlowRow{
          src: %Node{id: "D", desc: "Does the individual meet any diagnostic criteria?"},
          event: "No not really",
          dest: %Node{id: "F", desc: "Not Medically Necessary"}
        }
      ]
    }

    assert {:ok, flow} == Flow.parse(mermaid_flow)
  end

end
