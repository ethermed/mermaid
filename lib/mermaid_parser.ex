defmodule MermaidParser do
  import NimbleParsec
  require Logger

  @alphanumeric [?a..?z, ?A..?Z, ?0..?9, ?_]
  # Yup. I used an ascii table. I'm basically Mark Watney.
  # https://www.asciitable.com/
  @not_shape [?\s..?!, ?*..?;, ??..?Z, ?^..?z]
  @not_shape_or_line [?\s..?!, ?*..?,, ?...?;, ??..?Z, ?^..?z]
  # @shape_end [?], ?>, ?)]

  # We don't generally care about spaces between interesting bits, so they're both optional and ignored.
  blankspace = optional(ignore(ascii_string([?\s], min: 1)))

  # the id of a node
  identifier =
    optional(blankspace)
    |> optional(ascii_string(@alphanumeric, min: 1))
    |> optional(ascii_char([??, ?!]))
    |> reduce({IO, :iodata_to_binary, []})
    |> concat(blankspace)
    |> tag(:id)

  # There are more shapes than this. Will need to upgrade this for completeness.
  shape_start =
    ignore(
      choice([
        string("["),
        string("<"),
        string("("),
        string("{")
      ])
    )

  shape_end =
    ignore(
      choice([
        string("]"),
        string(">"),
        string(")"),
        string("}")
      ])
    )

  # The description of a node can be quoted or unquoted.
  quoted_desc =
    ignore(string("\""))
    |> utf8_string([not: ?\"..?\"], min: 1)
    |> ignore(string("\""))
    |> lookahead(shape_end)
    |> ignore(shape_end)

  unquoted_desc =
    ascii_string(@not_shape, min: 1)
    |> ignore(shape_end)

  desc =
    shape_start
    |> choice([quoted_desc, unquoted_desc])
    |> tag(:desc)

  complete_id = identifier |> optional(desc)

  defparsec(:nodee, complete_id)

  def parse_node(input), do: nodee(input) |> parse_response()

  @line [?-, ?=]
  @arrow [?>]
  line = ignore(ascii_string(@line, min: 1))
  arrow = ignore(ascii_char(@arrow))
  pipe = ignore(string("|"))
  newline = ignore(ascii_char([?\n]))
  # ignore_rest_of_line = ignore(blankspace) |> ignore(newline)

  pipe_event =
    arrow
    |> concat(pipe)
    |> ascii_string([not: ?|], min: 1)
    |> concat(pipe)
    |> reduce({__MODULE__, :trim, []})
    |> concat(blankspace)
    |> tag(:event)

  inline_event =
    optional(blankspace)
    |> ascii_string(@not_shape_or_line, min: 1)
    |> concat(line)
    |> concat(arrow)
    |> reduce({__MODULE__, :trim, []})
    |> concat(blankspace)
    |> tag(:event)

  nameless_event =
    optional(blankspace)
    # |> concat(line)
    |> concat(arrow)
    |> replace("empty")
    |> optional(blankspace)
    |> tag(:event)

  event =
    optional(blankspace)
    |> concat(line)
    |> choice([inline_event, pipe_event, nameless_event])

  defparsec(:event, event)
  def parse_event(input), do: event(input) |> parse_response

  complete_line =
    tag(complete_id, :src)
    |> optional(blankspace)
    |> concat(event)
    |> optional(blankspace)
    |> concat(tag(complete_id, :dest))
    |> tag(:row)
    |> optional(newline)

  defparsec(:complete_line, complete_line)
  def parse_complete_line(input), do: complete_line(input) |> parse_response

  flowchart_header =
    ignore(string("flowchart"))
    |> ignore(blankspace)
    |> ignore(choice([string("TD"), string("TB"), string("BT"), string("RL"), string("LR")]))
    |> optional(blankspace)
    |> optional(newline)

  defparsec(:flowchart_header, flowchart_header)
  def parse_header(input), do: flowchart_header(input) |> IO.inspect() |> parse_response

  malformed =
    optional(utf8_string([not: ?\n], min: 1))
    |> string("\n")
    |> pre_traverse(:abort)

  flow_parse = times(choice([flowchart_header, complete_line, malformed]), min: 1)

  defparsec(:flow, flow_parse)
  def parse_flow(input), do: flow(input) |> parse_response

  defp parse_response({:ok, [], rem, _, _, _}), do: {:ok, nil, rem}
  defp parse_response({:ok, result, rem, _, _, _}), do: {:ok, result, rem}
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
       "|||malformed (line: #{line}, column: #{column - offset})"}
  end

  def trim([input]), do: String.trim(input)
end
