defmodule Stacker do
  use Application.Behaviour

  def start(_type, stack) do
    Stacker.Supervisor.start_link(stack)
  end
end
