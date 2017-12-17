defmodule Identicon do
  alias Identicon.{ Image }

  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Image{ hex: hex }
  end

  def pick_color(image) do
    %Image{ hex: [ r, g, b | _ ] } = image

    %Image{ image | color: { r, g, b } }
  end

  def build_grid(image) do
    grid =
      image.hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Image{ image | grid: grid }
  end

  def mirror_row(row) do
    [ first, second | _ ] = row

    row ++ [ second, first ]
  end

  def filter_odd_squares(image) do
    grid = image.grid
    |> Enum.filter(fn( { code, _ }) ->
      rem(code, 2) == 0
    end)

    %Image{ image | grid: grid }
  end

  def build_pixel_map(image) do
    grid = image.grid

    pixel_map = Enum.map grid, fn({ _, index }) ->
      horizontal = rem(index, 5) * 50
      vertical   = div(index, 5) * 50

      top_left     = { horizontal, vertical }
      bottom_right = { horizontal + 50, vertical + 50 }

      { top_left, bottom_right }
    end

    %Image{ image | pixel_map: pixel_map }
  end

  def draw_image(image) do
    %Image{ color: color, pixel_map: pixel_map } = image

    image = :egd.create(250, 250)
    fill  = :egd.color(color)

    Enum.each pixel_map, fn({ start, stop }) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end
end
