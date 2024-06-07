import Config

if Mix.env == :dev do
  IO.puts("CLEARING")
  config :mix_test_watch,
    clear: true
end
