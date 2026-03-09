import React, { useState, useCallback, useEffect } from 'react';
import { GoogleMap, useJsApiLoader, Marker, Polyline, HeatmapLayer, DirectionsRenderer } from '@react-google-maps/api';

const containerStyle = {
  width: '100%',
  height: '100%'
};

const defaultCenter = {
  lat: 11.0168,
  lng: 76.9558
};

const libraries = ['visualization'];

const MapComponent = ({
  center,
  zoom = 12,
  markers = [],
  paths = [],
  heatmapData = [],
  children
}) => {
  const apiKey = import.meta.env.VITE_GOOGLE_MAPS_API_KEY;
  const isKeyConfigured = apiKey && apiKey !== 'YOUR_GOOGLE_MAPS_API_KEY_HERE';

  const { isLoaded, loadError } = useJsApiLoader({
    id: 'google-map-script',
    googleMapsApiKey: isKeyConfigured ? apiKey : '',
    libraries: libraries
  });

  const [map, setMap] = useState(null);
  const [directions, setDirections] = useState([]);

  // Fetch real road directions if paths are requested as "real"
  useEffect(() => {
    if (isLoaded && paths.length > 0) {
      console.log('[MapComponent] Fetching real road directions for', paths.filter(p => p.real).length, 'paths');
      const directionsService = new window.google.maps.DirectionsService();

      const fetchDirections = async () => {
        const results = await Promise.all(
          paths.map(path => {
            if (path.real && path.coords.length >= 2) {
              return new Promise((resolve) => {
                directionsService.route(
                  {
                    origin: path.coords[0],
                    destination: path.coords[path.coords.length - 1],
                    waypoints: path.coords.slice(1, -1).map(c => ({ location: c, stopover: false })),
                    travelMode: window.google.maps.TravelMode.DRIVING,
                  },
                  (result, status) => {
                    if (status === window.google.maps.DirectionsStatus.OK) {
                      resolve({ ...result, color: path.color, weight: path.weight });
                    } else {
                      console.warn('[MapComponent] Directions request failed:', status);
                      resolve(null);
                    }
                  }
                );
              });
            }
            return null;
          })
        );
        setDirections(results.filter(r => r !== null));
      };

      fetchDirections();
    }
  }, [isLoaded, paths]);

  const heatPoints = React.useMemo(() => {
    if (!isLoaded || heatmapData.length === 0) return [];
    return heatmapData.map(p => ({
      location: new window.google.maps.LatLng(p.lat, p.lng),
      weight: parseFloat(p.weight || 1) * 2 // Scale weight for better visibility
    }));
  }, [isLoaded, heatmapData]);

  const onLoad = useCallback(function callback(mapInstance) {
    if (paths.length > 0 || markers.length > 0 || heatmapData.length > 0) {
      const bounds = new window.google.maps.LatLngBounds();

      markers.forEach(marker => bounds.extend(marker.position));
      paths.forEach(path => {
        path.coords.forEach(coord => bounds.extend(coord));
      });
      heatmapData.forEach(point => bounds.extend({ lat: point.lat, lng: point.lng }));

      mapInstance.fitBounds(bounds);
    }
    setMap(mapInstance);
  }, [markers, paths, heatmapData]);

  const onUnmount = useCallback(function callback() {
    setMap(null);
  }, []);

  if (!isKeyConfigured) {
    return (
      <div className="w-full h-full flex flex-col items-center justify-center bg-gray-100 rounded-lg p-4 text-center">
        <p className="text-red-500 font-semibold mb-2">Map Configuration Required</p>
        <p className="text-gray-600 text-sm">Please set VITE_GOOGLE_MAPS_API_KEY in admin/.env</p>
      </div>
    );
  }

  if (loadError) {
    return (
      <div className="w-full h-full flex items-center justify-center bg-red-50 rounded-lg">
        <p className="text-red-500">Error loading map: {loadError.message}</p>
      </div>
    );
  }

  if (!isLoaded) {
    return (
      <div className="w-full h-full flex items-center justify-center bg-gray-100 rounded-lg">
        <p className="text-gray-500">Loading Map...</p>
      </div>
    );
  }

  return (
    <GoogleMap
      mapContainerStyle={containerStyle}
      center={center || defaultCenter}
      zoom={zoom}
      onLoad={onLoad}
      onUnmount={onUnmount}
      options={{
        zoomControl: true,
        streetViewControl: false,
        mapTypeControl: false,
        fullscreenControl: true,
      }}
    >
      {/* Heatmap Layer */}
      {heatPoints.length > 0 && (
        <HeatmapLayer
          data={heatPoints}
          options={{
            radius: 50, // Increased radius for better "heat" visibility
            opacity: 0.8,
            dissipating: true
          }}
        />
      )}

      {/* Render Real Road Directions */}
      {directions.map((dir, index) => (
        <DirectionsRenderer
          key={`dir-${index}`}
          directions={dir}
          options={{
            polylineOptions: {
              strokeColor: dir.color || '#10b981',
              strokeWeight: dir.weight || 6,
              strokeOpacity: 0.9
            },
            preserveViewport: true,
            suppressMarkers: true
          }}
        />
      ))}

      {/* Render simple paths (if not real directions or if directions fail) */}
      {paths.filter(p => !p.real).map((path, index) => (
        <Polyline
          key={`path-${index}`}
          path={path.coords}
          options={{
            strokeColor: path.color || '#3b82f6',
            strokeOpacity: path.opacity || 0.8,
            strokeWeight: path.weight || 4,
          }}
        />
      ))}

      {/* Render markers */}
      {markers.map((marker, index) => (
        <Marker
          key={`marker-${index}`}
          position={marker.position}
          title={marker.title}
          onClick={marker.onClick}
          icon={marker.icon}
        />
      ))}

      {children}
    </GoogleMap>
  );
};

export default React.memo(MapComponent);
