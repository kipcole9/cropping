defmodule Cropping do
  alias Vix.Vips.Image, as: Vimage

  @datafile "priv/croppointscapture.csv"
  @opaqu 255
  @transparent 0
  @transparent_white [255, 255, 255, @transparent]
  @radius 3

  @doc """
  Plot the points from a stream onto a
  transparent background image.

  """
  def plot(stream, width \\ 2000) do
    # Get the range of the original data
    {max_x, max_y} = data_range()

    # Using the original data, establish what the
    # height needs to be to preserve the ratio
    height = trunc(width * max_y / max_x)

    # Create a base image
    {:ok, image} = Image.new(width, height, bands: length(@transparent_white), color: @transparent_white)

    # For each row in the stream, plot its value with the
    # required color, making sure the color is opaque.
    Vimage.mutate image, fn mutable_image ->
      Enum.each(stream, fn [x, y, color] ->
        x = String.to_integer(x) |> convert_to_range(1, width, 1, max_x)
        y = String.to_integer(y) |> convert_to_range(1, height, 1, max_y)
        [r, g, b] = Image.Color.rgb_color(color)
        color = [r, g, b, @opaqu]

        # This is a low level API call. In an updated version
        # of Image I will add a function Image.draw but this
        # function will still remain
        :ok = Vix.Vips.MutableImage.draw_circle(mutable_image, color, x, y, @radius, fill: true)
      end)
    end
  end

  @doc """
  Returns a stream of CSV rows

  """
  def data_stream(path \\ @datafile) do
    path
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream()
  end

  # Converts an integer in the data range to the
  # right value in the image size
  defp convert_to_range(int, new_min, new_max, old_min, old_max) do
     round(((int - 1) / (old_max - old_min)) * (new_max - new_min) + new_min)
  end

  # Work out what the max x and y values of the
  # data are
  defp data_range do
    Enum.reduce(data_stream(), {0, 0}, fn [x, y, _color], {max_x, max_y} ->
      x = String.to_integer(x)
      y = String.to_integer(y)

      {max(x, max_x), max(y, max_y)}
    end)
  end

end
