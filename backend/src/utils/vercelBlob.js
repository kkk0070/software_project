import { put, del } from '@vercel/blob';
import dotenv from 'dotenv';
import fs from 'fs/promises';

dotenv.config();

/**
 * Upload a file to Vercel Blob storage
 * @param {string} filePath - Path to the file on local disk
 * @param {string} pathname - Name of the file in the blob storage
 * @returns {Promise<Object>} - Blob upload response
 */
export const uploadToBlob = async (filePath, pathname) => {
    try {
        if (!process.env.BLOB_READ_WRITE_TOKEN) {
            console.warn('[WARNING] BLOB_READ_WRITE_TOKEN not configured. Falling back to local/ephemeral storage.');
            return null;
        }

        const fileBuffer = await fs.readFile(filePath);
        const blob = await put(pathname, fileBuffer, {
            access: 'public',
            token: process.env.BLOB_READ_WRITE_TOKEN
        });

        return blob;
    } catch (error) {
        console.error('Vercel Blob upload error:', error);
        throw error;
    }
};

/**
 * Delete a file from Vercel Blob
 * @param {string} url - URL of the file in Vercel Blob
 * @returns {Promise<void>}
 */
export const deleteFromBlob = async (url) => {
    try {
        if (!url || !process.env.BLOB_READ_WRITE_TOKEN) return;
        await del(url, {
            token: process.env.BLOB_READ_WRITE_TOKEN
        });
    } catch (error) {
        console.error('Vercel Blob delete error:', error);
        throw error;
    }
};
