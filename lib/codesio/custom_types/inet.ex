defmodule Codesio.Inet do
  @behaviour Ecto.Type
  alias Postgrex.INET
  def type, do: :inet

  def cast(nil), do: { :error, nil }

  def cast(str) when is_binary(str) do
    [ip | net] = String.split(str, "/")
    case net do
      [] -> {:ok, {ip, nil}}
      _ -> {:ok, {ip, hd(net)}}
    end
  end

  def cast(tup) when is_tuple(tup) do
    {:ok, tup}
  end

  def cast(%INET{} = val) do

  end

  def cast(%{ip: ip, net: net} = map) when is_map(map) do
    {:ok, {ip, net}}
  end

  def cast(_), do: :error
  def dump(str) when is_binary(str) do
    [ip | net] = String.split(str)
    {:ok, %{ip: ip, net: net}}
  end

  def dump({ip_str, net} = val) do
    {status, ip} = :inet.parse_address(to_charlist(ip_str))
    if status == :ok do
      case net do
        nil -> {:ok, %INET{address: ip}}
        _ -> {:ok, %INET{address: ip}}
      end
    else
      :error
    end
  end

  def dump(_), do: :error

  def load(%INET{} = ip_struct) do
    ip_str = ip_struct.address
      |> Tuple.to_list
      |> Enum.join(".")
    {:ok, ip_str}
  end
  def load(_), do: :error
end
