{:ok, image} = Cropping.data_stream() |> Cropping.plot()
Image.write image, "cropping.png"