defmodule ChannelDemo.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    IO.puts "IN"
    broadcast! socket, "new_msg", %{body: body}
    {:noreply, socket}
  end

  intercept ["new_msg"]

  def handle_out("new_msg", payload, socket) do
    IO.puts "OUT"
    push socket, "new_msg", payload
    {:noreply, socket}
  end

end