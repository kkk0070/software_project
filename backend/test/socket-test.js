/**
 * Test script for Socket.io notification functionality
 * This script simulates a ride booking notification
 */
import http from 'http';
import { io as Client } from 'socket.io-client';

const TEST_URL = 'http://localhost:5000';
const DRIVER_USER_ID = 2; // Assuming driver user ID is 2

console.log('🧪 Socket.io Notification Test');
console.log('================================\n');

// Create a socket client connection
const socket = Client(TEST_URL, {
  transports: ['websocket', 'polling']
});

socket.on('connect', () => {
  console.log('[SUCCESS] Connected to WebSocket server');
  console.log(`   Socket ID: ${socket.id}\n`);

  // Register as a driver user
  console.log(`📝 Registering as driver (User ID: ${DRIVER_USER_ID})...`);
  socket.emit('register', DRIVER_USER_ID);

  setTimeout(() => {
    console.log('\n📨 Simulating ride booking notification...\n');

    // Simulate creating a ride via API
    fetch(`${TEST_URL}/api/rides`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        rider_id: 1,
        driver_id: DRIVER_USER_ID,
        pickup_location: 'New York, NY',
        dropoff_location: 'Brooklyn, NY',
        pickup_lat: 40.7128,
        pickup_lng: -74.0060,
        dropoff_lat: 40.6782,
        dropoff_lng: -73.9442,
        ride_type: 'Solo',
        fare: 25.50,
        distance: 10.5
      })
    })
    .then(response => response.json())
    .then(data => {
      console.log('📍 Ride created via API:');
      console.log('   Status:', data.success ? '[SUCCESS] Success' : '[ERROR] Failed');
      console.log('   Message:', data.message);
      if (data.data) {
        console.log('   Ride ID:', data.data.id);
      }
    })
    .catch(error => {
      console.error('[ERROR] Error creating ride:', error.message);
    });
  }, 2000);
});

socket.on('notification', (notification) => {
  console.log('🔔 NOTIFICATION RECEIVED!');
  console.log('   Title:', notification.title);
  console.log('   Message:', notification.message);
  console.log('   Type:', notification.type);
  console.log('   Category:', notification.category);
  if (notification.ride_id) {
    console.log('   Ride ID:', notification.ride_id);
  }
  console.log('   Time:', notification.created_at);

  // Acknowledge notification
  socket.emit('notification:acknowledge', {
    notification_id: notification.id,
    received_at: new Date()
  });

  console.log('\n[SUCCESS] Test completed successfully!');
  console.log('   Live notifications are working!\n');

  // Clean up and exit
  setTimeout(() => {
    socket.disconnect();
    process.exit(0);
  }, 1000);
});

socket.on('connect_error', (error) => {
  console.error('[ERROR] Connection error:', error.message);
  process.exit(1);
});

socket.on('disconnect', () => {
  console.log('[DISCONNECTED] Disconnected from WebSocket server');
});

// Timeout after 30 seconds
setTimeout(() => {
  console.log('\n[WARNING]  Test timeout - no notification received');
  socket.disconnect();
  process.exit(1);
}, 30000);
