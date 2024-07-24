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

  test "large flow parse" do
    mermaid_flow = """
    flowchart TD
    A["Is there documented anal cancer?"] -->|Yes| B["Is the imaging for Diagnostic Workup?"]
    A -->|No| Z["Procedure not Medically Necessary"]

    B -->|Yes| C["Is it a CT Chest?"]
    B -->|No| D["Is the imaging for Management?"]

    C -->|Yes| E["Procedure Medically Necessary"]
    C -->|No| F["Is it a CT Abdomen and Pelvis?"]

    F -->|Yes| G["Procedure Medically Necessary"]
    F -->|No| H["Is it an MRI Pelvis?"]

    H -->|Yes| I["Procedure Medically Necessary"]
    H -->|No| J["Is it an FDG-PET/CT?"]

    J -->|Yes| K["Can standard imaging be performed and is it diagnostic for metastatic disease?"]
    K -->|Yes| L["Procedure not Medically Necessary"]
    K -->|No| M["Procedure Medically Necessary"]

    D -->|Yes| N["Is it a CT Chest?"]
    D -->|No| O["Is the imaging for Surveillance?"]

    N -->|Yes| P["Procedure Medically Necessary"]
    N -->|No| Q["Is it a CT Abdomen and Pelvis?"]

    Q -->|Yes| R["Procedure Medically Necessary"]
    Q -->|No| S["Is it an MRI Pelvis?"]

    S -->|Yes| T["Procedure Medically Necessary"]
    S -->|No| U["Is it an FDG-PET/CT?"]

    U -->|Yes| V["Is it for radiation planning for definitive treatment or is standard imaging nondiagnostic for recurrent or progressive disease?"]
    V -->|Yes| W["Procedure Medically Necessary"]
    V -->|No| X["Procedure not Medically Necessary"]

    O -->|Yes| Y["Is it a CT Chest?"]
    O -->|No| AA["Procedure not Medically Necessary"]

    Y -->|Yes| BB["Is it especially useful in T3-4 tumors in the first 3 years?"]
    BB -->|Yes| CC["Procedure Medically Necessary"]
    BB -->|No| DD["Procedure not Medically Necessary"]

    Y -->|No| EE["Is it a CT Abdomen and Pelvis?"]
    EE -->|Yes| FF["Is it especially useful in T3-4 tumors in the first 3 years?"]
    FF -->|Yes| GG["Procedure Medically Necessary"]
    FF -->|No| HH["Procedure not Medically Necessary"]

    EE -->|No| II["Is it an MRI Pelvis?"]
    II -->|Yes| JJ["Procedure Medically Necessary"]
    II -->|No| KK["Procedure not Medically Necessary"]
    """

    assert {:ok, _actual_flow} = Mermaid.parse(mermaid_flow)
  end
end
