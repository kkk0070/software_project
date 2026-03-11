import { v2 as cloudinary } from 'cloudinary';
import dotenv from 'dotenv';
import fs from 'fs';

dotenv.config();

// Configuration
cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
});

/**
 * Upload a file to Cloudinary
 * @param {string} filePath - Path to the file on local disk
 * @param {string} folder - Folder name in Cloudinary
 * @returns {Promise<Object>} - Cloudinary upload response
 */
export const uploadToCloudinary = async (filePath, folder = 'ecoride/documents') => {
    try {
        if (!process.env.CLOUDINARY_CLOUD_NAME || !process.env.CLOUDINARY_API_KEY || !process.env.CLOUDINARY_API_SECRET) {
            console.warn('[WARNING] Cloudinary credentials not fully configured. Falling back to local/ephemeral storage.');
            return null;
        }

        const result = await cloudinary.uploader.upload(filePath, {
            folder: folder,
            resource_type: 'auto', // Automatically detect file type (image, video, raw)
            use_filename: true,
            unique_filename: true,
        });

        return result;
    } catch (error) {
        console.error('Cloudinary upload error:', error);
        throw error;
    }
};

/**
 * Delete a file from Cloudinary
 * @param {string} publicId - Public ID of the file in Cloudinary
 * @returns {Promise<Object>} - Cloudinary delete response
 */
export const deleteFromCloudinary = async (publicId) => {
    try {
        if (!publicId) return null;
        const result = await cloudinary.uploader.destroy(publicId);
        return result;
    } catch (error) {
        console.error('Cloudinary delete error:', error);
        throw error;
    }
};

export default cloudinary;
