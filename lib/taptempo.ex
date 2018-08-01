defmodule Taptempo do
  def main(args) do
    {opts, _, _} = OptionParser.parse(
      args,
      aliases: [p: :precision, r: :reset_time, s: :sample_size, h: :help],
      strict: [precision: :integer, reset_time: :integer, help: :boolean ]
    )

    state = %{
      precision: opts[:precision] ||  0,
      reset_time: opts[:reset_time] || 5,
      sample_size: opts[:sample_size] || 5,
      taps: [],
      last_activity: nil
    }

    case opts[:help] do
      true -> print_help()
      _ -> run(state)
    end
  end


  defp run(state) do
    IO.puts("Appuyez sur la touche entrée en cadence (q pour quitter).")   
    wait_for_input(state)
  end
  

  defp wait_for_input(state = %{taps: []}) do
    IO.gets("")
    new_state = put_in(state.taps, [now()])
    wait_for_input(new_state)
  end


  defp wait_for_input(state = %{taps: [_first_and_only_tap]}) do
    IO.puts("Appuyez encore sur la touche entrée pour lancer le calcul du tempo.")
    new_state = tap(state, now())
    wait_for_input(new_state)
  end


  defp wait_for_input(state) do
    case String.trim(IO.gets("")) do
      "" ->
        new_state = tap(state, now())
        if length(new_state.taps) >= 2, do: IO.puts("Tempo : #{format(estimate_bpm(new_state), state.precision)} BPM")
        wait_for_input(new_state)
      "q" ->
        quit(state)
    end    
  end

  
  defp tap(state, timestamp) do
    inactivity = (timestamp - (state.last_activity || timestamp))
    if inactivity > state.reset_time * 1000 do
      state
        |> put_in([:taps], [timestamp])
        |> put_in([:last_activity], timestamp)
    else
      state
        |> update_in([:taps], fn (taps) -> [timestamp|taps] end)
        |> put_in([:last_activity], timestamp)
    end
  end


  defp quit(state) do
    IO.puts("Tempo final : #{format(calculate_bpm(state), state.precision)} BPM")
    IO.puts("Au revoir !")
  end


  defp calculate_bpm(%{taps: all_taps, sample_size: sample_size}) do
    taps = Enum.take(all_taps, sample_size)
    last_tap = List.first(taps)
    first_tap = List.last(taps)
    1000 * (length(taps) - 1) / (last_tap - first_tap) * 60
  end


  defp estimate_bpm(%{taps: [last_tap|[previous_tap|_]]}) do
    1000 / (last_tap - previous_tap) * 60
  end


  defp format(bmp, 0), do: trunc(Float.round(bmp, 0))
  defp format(bmp, precision), do: Float.round(bmp, precision)


  defp now(), do: System.system_time(:milliseconds)


  defp print_help() do
    IO.puts("
    -h, --help            affiche ce message d'aide
    -p, --precision       changer le nombre de décimale du tempo à afficher
                          la valeur par défaut est 0 décimales, le max est 5 décimales
    -r, --reset-time      changer le temps en seconde de remise à zéro du calcul
                          la valeur par défaut est 5 secondes
    -s, --sample-size     changer le nombre d'échantillons nécessaires au calcul du tempo
                          la valeur par défaut est 5 échantillons
    ")
  end
end
