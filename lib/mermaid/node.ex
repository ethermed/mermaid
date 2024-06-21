defmodule Mermaid.Node do
  defstruct [:id, :desc]

  @type t :: %__MODULE__{
          id: String.t(),
          desc: String.t()
        }
end
