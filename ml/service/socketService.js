const socketService = {
    connected: false,
    connect: () => {
        socketService.connected = true;
        console.log('Socket connected');
    },
    disconnect: () => {
        socketService.connected = false;
        console.log('Socket disconnected');
    },
    emit: (event, data) => {
        if (!socketService.connected) return false;
        console.log(`Emitting ${event}:`, data);
        return true;
    }
};

export default socketService;
