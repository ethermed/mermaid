defmodule MermaidTest do
  use ExUnit.Case
  doctest Mermaid
  alias Mermaid

  describe "parse/1" do
    test "with a valid flowchart, returns {:ok, Flow}" do
    end

    test "with an invalid flowchart, returns {:error, reason, detail}" do
    end
  end
end
