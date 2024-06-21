defmodule Mermaid.FlowRow do
  defstruct [:src, :dest, :event]

  @type t :: %__MODULE__{
          src: Mermaid.Node.t(),
          event: String.t(),
          dest: Mermaid.Node.t()
        }
end
