defmodule State do
  @derive [Poison.Encoder]
  defstruct id: nil, stage: "started", name: nil, results: nil

  def set(id, value) do
    Redix.command(:redix, ["SET", id, Poison.encode!(value)])
  end

  def get(id) do
    {:ok, state} = Redix.command(:redix, ["GET", id])
    Poison.decode!(state, as: %State{})
  end

  def clear(id) do
    Redix.command(:redix, ["SET", id, Poison.encode!(%State{id: id})])
  end

  def update_stage(id, new_stage) do
    state = get(id)
    new_state = %{state | stage: new_stage}
    set(id, new_state)
    new_state
  end

  def update_name(id, new_name) do
    state = get(id)
    new_state = %{state | name: new_name}
    set(id, new_state)
    new_state
  end

  def update_results(id, results) do
    state = get(id)
    new_state = %{state | results: results}
    set(id, new_state)
    new_state
  end
end