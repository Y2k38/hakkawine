defimpl String.Chars, for: Tuple do
  def to_string(tuple) do
    case :inet.ntoa(tuple) do
      {:error, _} -> inspect(tuple)
      charlist -> List.to_string(charlist)
    end
  end
end
