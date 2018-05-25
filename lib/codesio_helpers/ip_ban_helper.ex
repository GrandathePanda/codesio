defmodule CodesioHelpers.IpBanHelper do
  @moduledoc """
    This module serves to assist with functions related to checking banned ips and custom plugs
    needed to enforce the ban.
  """
  defmodule ActiveBansAgent do
    use Agent
    alias Codesio.IpControl
    def start_link() do
      banned_ips = IpControl.list_banned_ips() |> Enum.map(fn bip -> bip.ip end)
      Agent.start_link(fn -> banned_ips end, name: __MODULE__)
    end

    def add_ip(ip) do
      Agent.cast(__MODULE__, fn(state) -> state ++ [ip] end)
    end

    def in_list?(ip) do
      Agent.get(__MODULE__, fn list ->
        ip in list
      end)
    end
    def get_all() do
      Agent.get(__MODULE__, fn state -> state end)
    end

    def remove_ip(ip) do
      Agent.cast(__MODULE__, fn state -> List.delete(state, ip) end)
    end
  end
  defmodule IpBanEnforcer do
    import Plug.Conn
    use PlugAttack
    rule "deny banned ips", conn do
      ip_address = conn.remote_ip |> Tuple.to_list |> Enum.join(".")
      block ActiveBansAgent.in_list?(ip_address)
    end

    def block_action(conn) do
      conn
      |> send_resp(:forbidden, "Forbidden\n")
      |> halt
    end
  end
end
