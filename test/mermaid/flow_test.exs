defmodule Mermaid.FlowTest do
  use ExUnit.Case
  doctest Mermaid.Flow
  alias Mermaid.Flow
  alias Mermaid.FlowRow
  alias Mermaid.Node

  test "new/1" do
    mermaid_flow = [
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

    assert {:ok, flow} == Flow.new(mermaid_flow)
  end
end
