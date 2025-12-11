defmodule MarketDataWeb.PageControllerTest do
  use MarketDataWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Phoenix Framework"
  end
end
