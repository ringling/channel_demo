defmodule ChannelDemo.PageController do
  use ChannelDemo.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
