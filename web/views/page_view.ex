defmodule Presenter.PageView do
  use Presenter.Web, :view

  def truncate(string) do
    orig = string
    str = orig |> String.slice(0..29) 
    unless String.at(orig, 30) == "-", do: str = str |> String.replace(~r{-[^-]*$}, "")
  end

end
