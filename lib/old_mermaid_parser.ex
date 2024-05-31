# defmodule OldMermaidParser do
#   import NimbleParsec

#   @string_head [?a..?z, ?A..?Z, ?0..?9, ?_]
#   @string_no_whitespace [?a..?z, ?A..?Z, ?0..?9, ?_, ??, ?!, ?-]
#   @string_whitespace [?a..?z, ?A..?Z, ?0..?9, ?_, ??, ?!, ?-, ?\s]
#   @string_tail [?a..?z, ?A..?Z, ?0..?9, ?_, ?\s, ??]
#   @label_end [?\], ?}, ?>]

#   # todo - convert ascii_string to utf string
#   blankspace = ignore(ascii_string([?\s], min: 1))
#   newline = ignore(ascii_char([?\n]))
#   transition_start = ignore(string("--"))
#   transition_op = string("-->")
#   label_start = ascii_char([?[, ?{, ?<])
#   label_end = ascii_char(@label_end)

#   # any string we want to keep together
#   single_string =
#     optional(blankspace)
#     |> optional(ascii_string(@string_no_whitespace, min: 1))
#     |> optional(blankspace)

#   sentence_string =
#     optional(blankspace)
#     # |> ascii_string([not: label_end], min: 1)
#     |> ascii_string(not: [?\], ?}, ?>], min: 1)
#     # |> optional(lookahead(string(" ")))
#     |> reduce({Enum, :join, []})
#     |> reduce({__MODULE__, :trim, []})

#   # [hi], {hi}, <hi>
#   label =
#     ignore(label_start)
#     |> optional(blankspace)
#     |> concat(sentence_string)
#     |> optional(blankspace)
#     |> ignore(label_end)


#   # id[label], id, id{label}, id<label>
#   step =
#     optional(blankspace)
#     |> concat(single_string)
#     |> optional(blankspace)
#     |> optional(label)
#     |> optional(blankspace)
#     |> reduce({__MODULE__, :id_coalesce, []})

#   # |event|, |event string|
#   event =
#     ignore(string("|"))
#     |> optional(blankspace)
#     |> concat(sentence_string)
#     |> optional(blankspace)
#     |> ignore(string("|"))

#   # -- event -->, -- event string -->, --event-->, --event string-->
#   inline_event =
#     optional(blankspace)
#     |> ignore(transition_start)
#     |> optional(blankspace)
#     |> concat(single_string)
#     |> debug()
#     |> optional(blankspace)
#     |> ignore(transition_op)
#     |> optional(blankspace)

#   # -->|event|
#   pipe_event =
#     optional(blankspace)
#     |> ignore(transition_op)
#     |> optional(blankspace)
#     |> concat(event)

#   # -->
#   no_event =
#     optional(blankspace)
#     |> ignore(transition_op)
#     |> optional(blankspace)

#   event =
#     choice([inline_event, pipe_event, no_event])

#   new_mermaid_line =
#     step
#     |> concat(event)
#     |> concat(step)
#     |> optional(ignore(newline))
#     |> tag(:line)

#   malformed =
#     optional(utf8_string([not: ?\n], min: 1))
#     |> string("\n")
#     |> pre_traverse(:abort)

#   # flowchart TD, flowchart LR
#   flowchart_header =
#     ignore(string("flowchart"))
#     |> ignore(blankspace)
#     |> ignore(choice([string("TD"), string("LR")]))
#     |> optional(blankspace)
#     |> optional(ignore(newline))

#   defparsec(:inline_event, inline_event)
#   defparsec(:event, event)
#   defparsec(:sentence, sentence_string)
#   defparsec(:label, label)
#   defparsec(:step, step)
#   defparsec(:flow, times(choice([flowchart_header, new_mermaid_line, malformed]), min: 1))

#   def parse_flow(input) do
#     case flow(input) do
#       {:ok, lines, _, _, _, _} ->
#         {:ok, lines}
#     end
#   end

#   def parse_step(input), do: step(input) |> parse_response()
#   def parse_label(input), do: label(input) |> parse_response()
#   def parse_sentence(input), do: sentence(input) |> parse_response()
#   def parse_event(input), do: event(input) |> parse_response()

#   defp parse_response({:ok, [], _, _, _, _}), do: {:ok, nil}
#   defp parse_response({:ok, result, _, _, _, _}), do: {:ok, result}

#   @spec abort(
#           String.t(),
#           [String.t()],
#           map(),
#           {non_neg_integer, non_neg_integer},
#           non_neg_integer
#         ) :: {:error, binary()}

#   defp abort(rest, content, _context, {line, column}, offset) do
#     content = content |> Enum.reverse() |> Enum.join() |> String.trim()
#     meta = inspect(line: line, column: column, offset: offset, rest: rest, content: content)

#     {:error,
#      meta <>
#        "|||malformed Flow transition (line: #{line}, column: #{column - offset}), expected `from --> |event| to`"}
#   end

#   def id_coalesce([id]), do: id
#   def id_coalesce([id, [label]]), do: {id, label}

#   def trim([input]), do: [String.trim(input)]
# end
