import os
import sys
import numpy as np
import pandas as pd
from osgeo import gdal, osr

def convert_csv_to_raster(csv_file, raster_file, pixel_size=1):
    """Converts a CSV file to a raster format."""
    try:
        # Read the CSV file
        data = pd.read_csv(csv_file)
    except Exception as e:
        print(f"Error reading CSV file {csv_file}: {e}")
        return
    
    if not {'EAST', 'NORTH', 'THICKNESS'}.issubset(data.columns):
        raise ValueError(f"CSV file {csv_file} is missing required columns.")

    # Get the min and max coordinates
    x_min, x_max = data['EAST'].min(), data['EAST'].max()
    y_min, y_max = data['NORTH'].min(), data['NORTH'].max()

    # Define resolution based on the provided pixel size
    x_res = int((x_max - x_min) / pixel_size) + 1
    y_res = int((y_max - y_min) / pixel_size) + 1

    # Create the GeoTIFF driver and output raster
    driver = gdal.GetDriverByName('GTiff')
    raster = driver.Create(raster_file, x_res, y_res, 1, gdal.GDT_Float32)

    if raster is None:
        print(f"Error creating raster file {raster_file}.")
        return
    
    # Set the geotransform and projection
    raster.SetGeoTransform((x_min, pixel_size, 0, y_max, 0, -pixel_size))
    srs = osr.SpatialReference()
    srs.ImportFromEPSG(2193)  # Example EPSG:2193 for NZ
    raster.SetProjection(srs.ExportToWkt())

    # Create a grid for the thickness data
    thickness_grid = np.full((y_res, x_res), np.nan)

    # Populate the grid with thickness values based on the CSV data
    for _, row in data.iterrows():
        x_index = int((row['EAST'] - x_min) / pixel_size)
        y_index = int((y_max - row['NORTH']) / pixel_size)
        thickness_grid[y_index, x_index] = row['THICKNESS']

    # Write the thickness grid to the raster band
    band = raster.GetRasterBand(1)
    band.WriteArray(thickness_grid)
    band.SetNoDataValue(np.nan)

    # Flush cache to write data to the file
    raster.FlushCache()
    print(f"Raster created successfully at {raster_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python lava_flow_rasterised.py <input_csv> <output_raster>")
        sys.exit(1)

    input_csv = sys.argv[1]
    output_raster = sys.argv[2]
    convert_csv_to_raster(input_csv, output_raster)
