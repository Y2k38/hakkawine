defmodule Hakkawine.Utils.CodeGenerator do
  @charset ~c"23456789ABCDEFGHJKLMNPQRSTUVWXYZ"

  def generate_invite_code(length \\ 8) do
    1..length
    |> Enum.map(fn _ -> Enum.random(@charset) end)
    |> List.to_string()
  end

  def generate_verification_code(length \\ 6) do
    1..length
    |> Enum.map(fn _ -> Enum.random(0..9) end)
    |> Enum.join()
  end

  def generate_reset_password_token(bytes_length \\ 24) do
    bytes_length
    |> :crypto.strong_rand_bytes()
    |> Base.encode16(case: :lower)
  end
end
