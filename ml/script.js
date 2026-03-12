const drivers = [
    { name: 'Rahul S.', lat: 12.9720, lng: 77.5950, rating: 4.8 },
    { name: 'Amit K.', lat: 12.9800, lng: 77.6000, rating: 4.9 },
    { name: 'Sriya M.', lat: 12.9650, lng: 77.5850, rating: 4.7 },
    { name: 'Vikram J.', lat: 13.0000, lng: 77.6200, rating: 4.6 }
];

// Haversine Formula for Distance Calculation
function calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Earth's radius in km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
}

// Nearest Neighbor Search for Driver
function findNearestDriver(userLat, userLng) {
    let nearest = null;
    let minDistance = Infinity;

    drivers.forEach(driver => {
        const dist = calculateDistance(userLat, userLng, driver.lat, driver.lng);
        if (dist < minDistance) {
            minDistance = dist;
            nearest = driver;
        }
    });

    return { driver: nearest, distance: minDistance };
}

// Export for tests if in Node environment
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { calculateDistance, findNearestDriver, drivers };
}

document.addEventListener('DOMContentLoaded', () => {
    const bookBtn = document.getElementById('book-btn');
    const resultsArea = document.getElementById('results');
    const modeCards = document.querySelectorAll('.mode-card');
    const pickupInput = document.getElementById('pickup');
    const destInput = document.getElementById('destination');
    const toast = document.getElementById('toast');

    // Initialize Map
    const map = L.map('map').setView([12.9716, 77.5946], 12);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap contributors'
    }).addTo(map);

    let pickupMarker, destMarker, routeLine;
    let heatLayer;
    let adminMode = false;

    const adminToggle = document.getElementById('admin-toggle');
    const adminDashboard = document.getElementById('admin-dashboard');

    function toggleAdminMode() {
        adminMode = !adminMode;
        if (adminMode) {
            adminToggle.classList.add('active');
            adminDashboard.classList.remove('hidden');
            showHeatmap();
            updateDashboard();
        } else {
            adminToggle.classList.remove('active');
            adminDashboard.classList.add('hidden');
            if (heatLayer) map.removeLayer(heatLayer);
        }
    }

    adminToggle.addEventListener('click', (e) => {
        e.preventDefault();
        toggleAdminMode();
    });

    function showHeatmap() {
        if (heatLayer) map.removeLayer(heatLayer);
        
        // Mocking some demand points for visualization
        const heatPoints = [
            [12.9716, 77.5946, 0.8],
            [12.9800, 77.6000, 0.6],
            [12.9650, 77.5850, 0.9],
            [13.0000, 77.6200, 0.4]
        ];

        heatLayer = L.heatLayer(heatPoints, { radius: 25, blur: 15, maxZoom: 17 }).addTo(map);
    }

    function updateDashboard() {
        document.getElementById('peak-demand-val').textContent = '145 units';
        document.getElementById('efficiency-val').textContent = '88%';
        
        const alerts = document.getElementById('opt-alerts');
        alerts.innerHTML = `
            <div class="alert warn">
                <i class="fas fa-exclamation-triangle"></i>
                <span>High demand expected in Koramangala. 3 drivers recommended to relocate.</span>
            </div>
        `;
    }

    function updateMap(pCoords, dCoords) {
        // Clear old markers
        if (pickupMarker) map.removeLayer(pickupMarker);
        if (destMarker) map.removeLayer(destMarker);
        if (routeLine) map.removeLayer(routeLine);

        // Add New Markers
        pickupMarker = L.marker(pCoords).addTo(map).bindPopup('Pickup').openPopup();
        destMarker = L.marker(dCoords).addTo(map).bindPopup('Destination');

        // Draw Route (Simple Line)
        routeLine = L.polyline([pCoords, dCoords], { color: '#00ff88', weight: 4, opacity: 0.8 }).addTo(map);

        // Fit map to show both points
        const group = new L.featureGroup([pickupMarker, destMarker]);
        map.fitBounds(group.getBounds().pad(0.1));
    }

    bookBtn.addEventListener('click', () => {
        const pickupVal = pickupInput.value.trim();
        const destVal = destInput.value.trim();

        if (!pickupVal || !destVal) {
            alert('Please enter both pickup and destination coordinates.');
            return;
        }

        // Parse coordinates
        let pCoords = pickupVal.split(',').map(n => parseFloat(n.trim()));
        let dCoords = destVal.split(',').map(n => parseFloat(n.trim()));

        if (isNaN(pCoords[0]) || isNaN(pCoords[1]) || isNaN(dCoords[0]) || isNaN(dCoords[1])) {
            alert('Invalid coordinate format. Please use: lat, lng');
            return;
        }

        updateMap(pCoords, dCoords);

        bookBtn.textContent = 'Finding Driver...';
        bookBtn.disabled = true;

        // Simulate Network Latency
        setTimeout(() => {
            const distance = calculateDistance(pCoords[0], pCoords[1], dCoords[0], dCoords[1]);
            const { driver, distance: driverDist } = findNearestDriver(pCoords[0], pCoords[1]);

            document.getElementById('distance-val').textContent = `${distance.toFixed(2)} km`;
            document.getElementById('driver-val').textContent = `${driver.name} (⭐${driver.rating})`;
            document.getElementById('eta-val').textContent = `${Math.ceil(driverDist * 2 + 2)} mins`;

            resultsArea.classList.remove('hidden');
            bookBtn.textContent = 'Book Now';
            bookBtn.disabled = false;

            // Show Toast
            toast.classList.remove('hidden');
            setTimeout(() => toast.classList.add('hidden'), 3000);
        }, 1500);
    });
});
