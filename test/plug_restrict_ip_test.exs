defmodule PlugRestrictIpTest do
  use ExUnit.Case
  use Plug.Test

  import ExUnit.CaptureLog

  defmacro assert_forbidden(conn) do
    quote do
      assert unquote(conn).status == 403
      assert unquote(conn).state == :set
      assert unquote(conn).halted == true
    end
  end

  defmacro assert_accepted(conn) do
    quote do
      assert unquote(conn).status == nil
      assert unquote(conn).state == :unset
      assert unquote(conn).halted == false
    end
  end

  test "restricts traffic by default" do
    conn = call({1, 1, 1, 1})

    assert_forbidden(conn)
  end

  test "warns only if log_only is set" do
    assert capture_log(fn ->
             conn = call({1, 1, 1, 1}, log_only: true)

             assert_accepted(conn)
           end) =~ "not whitelisted"
  end

  test "allows single cidr" do
    conn = call({1, 1, 1, 1}, allow: :single_cidr)

    assert_accepted(conn)
  end

  test "allows single cidr with allow list" do
    conn = call({1, 1, 1, 1}, allow: [:single_cidr])

    assert_accepted(conn)
  end

  test "allows multiple cidrs" do
    conn = call({1, 1, 1, 1}, allow: :multiple_cidrs)

    assert_accepted(conn)
  end

  test "allows multiple cidrs with keys" do
    conn = call({1, 1, 1, 1}, allow: :multiple_cidrs_with_keys)

    assert_accepted(conn)
  end

  test "deny ip outside of multiple cidrs" do
    conn = call({2, 2, 2, 4}, allow: [:multiple_cidrs_with_keys])

    assert_forbidden(conn)
  end

  test "allow ip inside multiple cidrs" do
    conn = call({2, 2, 2, 3}, allow: [:multiple_cidrs_with_keys])

    assert_accepted(conn)
  end

  test "does not allow traffic when remote_ip is not set" do
    conn = call(nil, allow: [:multiple_cidrs_with_keys])

    assert_forbidden(conn)
  end

  test "allows a cidr range" do
    conn = call(nil, allow: [:multiple_cidrs_with_keys])

    assert_forbidden(conn)
  end

  test "allows cidr string list not in config" do
    conn = call({1, 1, 1, 1}, allow: ["1.1.1.1/32"])

    assert_accepted(conn)
  end

  test "allows cidr string not in config" do
    conn = call({1, 1, 1, 1}, allow: "1.1.1.1/32")

    assert_accepted(conn)
  end

  test "allows inside range" do
    conn = call({1, 1, 1, 88}, allow: "1.1.1.0/24")

    assert_accepted(conn)
  end

  test "forbid outside range" do
    conn = call({1, 1, 2, 1}, allow: "1.1.1.0/24")

    assert_forbidden(conn)
  end

  test "handle bad config gracefully?? how" do
  end

  defp call(ip, opts \\ []) do
    conn(:get, "/restricted")
    |> Map.merge(%{remote_ip: ip})
    |> PlugRestrictIp.call(opts)
  end
end
