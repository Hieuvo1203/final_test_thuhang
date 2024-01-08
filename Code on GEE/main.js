var Countries = ee.FeatureCollection("USDOS/LSIB_SIMPLE/2017");
var roi = Countries.filter(ee.Filter.eq('country_na', 'India'));
Map.addLayer(roi, {}, 'India', false);
Map.centerObject(roi);

var dataset = ee.ImageCollection('NASA_USDA/HSL/SMAP10KM_soil_moisture')
                  .filter(ee.Filter.date('2022-01-01', '2022-01-31'))
                  .filterBounds(roi);
var soilMoisture = dataset.select('ssm').median();
var soilMoistureVis = {
  min: 0.0,
  max: 28.0,
  palette: ['0300ff','418504','efff07','efff07','ff0303'],
};
Map.addLayer(soilMoisture, soilMoistureVis, 'Global Soil Moisture');
Map.addLayer(soilMoisture.clip(roi), soilMoistureVis, 'India Soil Moisture');
Map.centerObject(roi, 6);

Export.image.toDrive({
  image: soilMoisture.clip(roi),
  description: 'SMAP_India',
  scale: 1000,
  region: roi,
  maxPixels: 1e13
});
