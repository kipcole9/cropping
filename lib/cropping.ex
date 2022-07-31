defmodule Cropping do

  @datafile "priv/croppointscapture.csv"
  @opaqu 255
  @transparent 0
  @transparent_white [255, 255, 255, @transparent]
  @radius 3

  @doc """
  Plot the points from a stream onto a
  transparent background image.

  """
  def plot(stream, image_width \\ 2000) do
    # Get the range of the original data
    {max_width, max_height} = data_range()

    # Using the original data, establish what the
    # height needs to be to preserve the ratio
    image_height = trunc(image_width * max_height / max_width)

    # Create a base image
    {:ok, image} = Image.new(image_width, image_height, bands: length(@transparent_white), color: @transparent_white)

    # For each row in the stream, plot its value with the
    # required color, making sure the color is opaque.
    Image.mutate image, fn mutable_image ->
      Enum.each(stream, fn [x, y, color] ->
        x = String.to_integer(x) |> convert_to_range(image_width, max_width)
        y = String.to_integer(y) |> convert_to_range(image_height, max_height)
        [r, g, b] = Image.Color.rgb_color(color)
        color = [r, g, b, @opaqu]

        :ok = Image.Draw.circle(mutable_image, x, y, @radius, color: color, fill: true)
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
  @old_min 1
  @new_min 1

  defp convert_to_range(int, current_max, original_max) do
    round(((int - 1) / (original_max - @old_min)) * (current_max - @new_min) + @new_min)
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
