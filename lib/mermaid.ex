defmodule Mermaid do
  alias Mermaid.Flow
  alias Mermaid.Parser

  @spec parse(String.t()) :: {:ok, Flow.t()} | {:error, atom()}
  def parse(mermaid_string) do
    case Parser.parse(mermaid_string) do
      {:ok, rows, _, _, _, _} ->
        Flow.new(rows)

      _ ->
        {:error, :mermaid_parse_error}
    end
  end
end
