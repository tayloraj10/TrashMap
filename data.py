#!/usr/bin/env python3
import json
import sys
import geojson
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)


def validate_geojson(file_path, simple):
    logging.info(f"Validating GeoJSON file: {file_path}")
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        logging.info("JSON file loaded successfully.")
    except json.JSONDecodeError as e:
        logging.error(f"Invalid JSON: {e}")
        return False
    except FileNotFoundError:
        logging.error(f"File not found: {file_path}")
        return False

    # Use geojson library to validate
    try:
        geojson_obj = geojson.loads(json.dumps(data))
        # Print each feature (row) if it's a FeatureCollection
        if isinstance(geojson_obj, geojson.FeatureCollection):
            features = geojson_obj['features']
            polygons = []
            id = 0
            for feature in features:
                properties = feature.get('properties', {})
                # Only process if STATEFP10 is '42'
                # if properties.get('ZCTA5CE10') != '17202':
                if properties.get('STATEFP10') != '42':
                    continue
                geometry = feature.get('geometry')
                if not geometry:
                    continue
                geom_type = geometry.get('type')
                if geom_type == 'Polygon':
                    coords_list = [geometry['coordinates']]
                elif geom_type == 'MultiPolygon':
                    coords_list = geometry['coordinates']
                else:
                    continue
                for coords in coords_list:
                    # coords is a list of linear rings, take the exterior ring (first)
                    exterior = coords[0]
                    points = [(p[1], p[0]) for p in exterior]
                    polygon = {
                        'polygonId': properties.get('ZCTA5CE10', f'poly_{id}'),
                        'points': points
                    }
                    polygons.append(polygon)
                    id += 1
                output_path = '/Users/taylor.johnson/Desktop/trashmap/assets/data/zipcode_data'
                if simple:
                    output_path += '_simple'
                output_path += '.json'
            with open(output_path, 'w', encoding='utf-8') as out_f:
                json.dump(polygons, out_f, indent=2)
            logging.info(f"Wrote {len(polygons)} polygons to {output_path}")
        if isinstance(geojson_obj, geojson.GeoJSON):
            logging.info("Valid GeoJSON!")
            return True
        else:
            logging.warning("Invalid GeoJSON object type.")
            return False
    except (TypeError, ValueError) as e:
        logging.error(f"GeoJSON validation error: {e}")
        return False


if __name__ == "__main__":
    simple = True
    file_path = "/Users/taylor.johnson/Desktop/trashmap/assets/data/usa_zip_codes_geo_100m"
    if simple:
        file_path += "_simple"
    file_path += ".json"
    valid = validate_geojson(file_path, simple)
    if valid:
        logging.info("GeoJSON validation succeeded.")
    else:
        logging.error("GeoJSON validation failed.")
