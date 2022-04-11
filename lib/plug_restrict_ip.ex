defmodule PlugRestrictIp do
  @moduledoc """
  Documentation for `PlugRestrictIp`.
  """

  import Plug.Conn

  require Logger

  def init(opts), do: opts

  def call(%Plug.Conn{path_info: _path_info} = conn, opts \\ []) do
    cidrs = Keyword.get(opts, :allow, []) |> get_allowed_cidrs()
    log_only = Keyword.get(opts, :log_only, false)

    global_cidrs = Application.get_env(:plug_restrict_ip, :global_cidrs, [])

    allowed_cidrs = cidrs ++ global_cidrs

    allow =
      allowed_cidrs
      |> Enum.map(&InetCidr.parse/1)
      |> Enum.any?(fn cidr ->
        InetCidr.contains?(cidr, conn.remote_ip)
      end)

    if allow do
      conn
    else
      case Application.get_env(:plug_restrict_ip, :log_only, log_only) do
        true ->
          Logger.warn("[PlugRestrictIp] #{incoming_ip(conn)} not whitelisted")
          conn

        _ ->
          conn
          |> put_resp_content_type("text/plain; charset=utf-8")
          |> resp(:forbidden, "Forbidden")
          |> halt()
      end
    end
  end

  defp incoming_ip(conn) do
    case conn.remote_ip do
      nil -> ""
      val -> to_string(:inet_parse.ntoa(val))
    end
  end

  defp get_allowed_cidrs(cidrs) when is_list(cidrs) do
    Enum.reduce(cidrs, [], fn cidr, acc ->
      acc ++ get_allowed_cidrs(cidr)
    end)
  end

  defp get_allowed_cidrs(cidrs) when is_binary(cidrs), do: [cidrs]

  defp get_allowed_cidrs(cidrs) when is_atom(cidrs) do
    case Application.get_env(:plug_restrict_ip, :cidrs)[cidrs] do
      cidrs when is_list(cidrs) ->
        Enum.map(cidrs, fn
          {_, cidr} -> cidr
          cidr -> cidr
        end)

      cidr when is_binary(cidr) ->
        [cidr]
    end
  end
end
