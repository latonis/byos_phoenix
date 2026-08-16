defmodule TrmnlWeb.DashboardLive.Index do
  use TrmnlWeb, :live_view

  alias Trmnl.Inventory
  alias Trmnl.Inventory.Device

  @impl true
  def mount(_params, session, socket) do
    ip = Map.get(session, "ip", "unknown")
    host = Map.get(session, "host", "unknown")

    devices =
      Inventory.list_devices()
      |> Enum.with_index()
      |> Enum.map(fn {device, i} -> Map.put(device, :index, i) end)

    {:ok,
     socket
     |> assign(:ip, ip)
     |> assign(:host, host)
     |> assign(:current_index, 0)
     |> assign(
       :devices,
       devices
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Device")
    |> assign(:device, Inventory.get_device!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Device")
    |> assign(:device, %Device{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Devices")
    |> assign(:device, nil)
  end

  @impl true
  def handle_info({TrmnlWeb.DeviceLive.FormComponent, {:saved, device}}, socket) do
    {:noreply, stream_insert(socket, :devices, device)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    device = Inventory.get_device!(id)
    {:ok, _} = Inventory.delete_device(device)

    {:noreply, stream_delete(socket, :devices, device)}
  end

  def handle_event("next", _params, socket) do
    total = length(socket.assigns.devices)
    new_index = rem(socket.assigns.current_index + 1, total)
    {:noreply, assign(socket, :current_index, new_index)}
  end

  def handle_event("previous", _params, socket) do
    total = length(socket.assigns.devices)
    new_index = rem(socket.assigns.current_index - 1, total)
    {:noreply, assign(socket, :current_index, new_index)}
  end

  @impl true
  def handle_async("set-index", %{"index" => index}, socket) do
    {:noreply, assign(socket, :current_index, String.to_integer(index))}
  end

  defp format_datetime(nil), do: "Never"

  defp format_datetime(dt) do
    Calendar.strftime(dt, "%b %d, %Y %I:%M %p")
  end
end
