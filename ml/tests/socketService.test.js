import { describe, it, expect } from 'vitest';
import socketService from '../services/socketService.js';

describe('socketService', () => {
    it('should handle connection status', () => {
        socketService.connect();
        expect(socketService.connected).toBe(true);
    });

    it('should handle disconnection', () => {
        socketService.disconnect();
        expect(socketService.connected).toBe(false);
    });

    it('should emit only when connected', () => {
        socketService.disconnect();
        expect(socketService.emit('test', {})).toBe(false);
        socketService.connect();
        expect(socketService.emit('test', {})).toBe(true);
    });
});
