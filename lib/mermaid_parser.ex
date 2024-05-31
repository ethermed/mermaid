defmodule MermaidParser do
  import NimbleParsec

  @alphanumeric [?a..?z, ?A..?Z, ?0..?9, ?_]
  # Yup. I used an ascii table. I'm basically Mark Watney.
  # https://www.asciitable.com/
  @not_shape [?\s..?!, ?*..?;, ??..?Z, ?^..?z]
  @shape_end [?], ?>, ?)]

  identifier =
    ascii_char([?a..?z])
    |> optional(ascii_string(@alphanumeric, min: 1))
    |> optional(ascii_char([??, ?!]))
    |> reduce({IO, :iodata_to_binary, []})
    |> tag(:id)

  shape_start =
    ignore(choice([
      string("["),
      string("<"),
      string("("),
    ]))

  shape_end =
    ignore(choice([
      string("]"),
      string(">"),
      string(")"),
    ]))

  quoted_desc =
    ignore(string("\""))
    |> utf8_string([not: ?\"..?\"], min: 1)
    |> ignore(string("\""))
    |> lookahead(shape_end)

  unquoted_desc =
    ascii_string(@not_shape, min: 1)
    |> ignore(shape_end)

  desc = shape_start
  |> choice([ quoted_desc, unquoted_desc ])
  |> tag(:desc)



  defparsec(:nodee, identifier |> optional(desc))

  def parse_node(input), do: nodee(input) |> parse_response()

  defp parse_response({:ok, [], _, _, _, _}), do: {:ok, nil}
  defp parse_response({:ok, result, _, _, _, _}), do: {:ok, result}
  # defp parse_response({:error, result, _, _, _, _}), do: {:ok, result}

  @spec abort(
          String.t(),
          [String.t()],
          map(),
          {non_neg_integer, non_neg_integer},
          non_neg_integer
        ) :: {:error, binary()}

  defp abort(rest, content, _context, {line, column}, offset) do
    content = content |> Enum.reverse() |> Enum.join() |> String.trim()
    meta = inspect(line: line, column: column, offset: offset, rest: rest, content: content)

    {:error,
     meta <>
       "|||malformed Flow transition (line: #{line}, column: #{column - offset}), expected `from --> |event| to`"}
  end
end
