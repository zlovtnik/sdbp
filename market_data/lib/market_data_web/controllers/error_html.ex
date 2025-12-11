defmodule MarketDataWeb.ErrorHTML do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on HTML requests.

  See config/config.exs.
  """
  use MarketDataWeb, :html

  # If you want to customize your error pages,
  # add pages to the error_html directory:
  #
  #   * lib/market_data_web/controllers/error_html/404.html.heex
  #   * lib/market_data_web/controllers/error_html/500.html.heex
  #
  # Templates under error_html/* are embedded by default.

  # The default is to render a plain text page based on
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
