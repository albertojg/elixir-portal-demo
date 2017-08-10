defmodule Portal do
  defstruct [:left, :right]

  @doc """
  Starts transferring `data` from `left` to `right`.
  """
  def transfer(left, right, data) do
    # First add all data to the portal on the left
    for item <- data do
      Portal.Door.push(left, item)
    end

    # Returns a portal struct we will use next
    %Portal{left: left, right: right}
  end

  @doc """
  Pushes data to the right in the given `portal`
  """
  def push_right(portal) do
    push(portal, :right)
  end

  @doc """
  Pushes data to the left in the given `portal`
  """
  def push_left(portal) do
    push(portal, :left)
  end

  @doc """
  Pushes data specified by the `direction` within the `portal`
  """
  def push(portal, direction) do
    source =
      case direction do
        :left  -> portal.right
        :right -> portal.left
      end

    sink = 
      case direction do
        :left  -> portal.left
        :right -> portal.right
      end

    # See if we can pop from source. If so, push the 
    # popped data to the sink. Otherwise, do nothing.
    case Portal.Door.pop(source) do
      :error   -> :ok
      {:ok, h} -> Portal.Door.push(sink, h)
    end

    portal
  end

  @doc """
  Shoots a new door with the given `color`
  """
  def shoot(color) do
    Supervisor.start_child(Portal.Supervisor, [color])
  end
end

defimpl Inspect, for: Portal do
  def inspect(%Portal{left: left, right: right}, _) do
    left_door = inspect(left)
    right_door = inspect(right)

    left_data = inspect(Enum.reverse(Portal.Door.get(left)))
    right_data = inspect(Portal.Door.get(right))

    max = max(String.length(left_door), String.length(left_data))

    """
    #Portal<
      #{String.pad_leading(left_door, max)} <=> #{right_door}
      #{String.pad_leading(left_data, max)} <=> #{right_data}
    >
    """
  end
end
