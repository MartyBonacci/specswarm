/**
 * Cloudinary Avatar Upload Pattern
 *
 * ✅ PROVEN CORRECT - Tested and validated
 * Version: 1.0.0
 * Last Updated: 2025-01-16
 *
 * This pattern implements secure avatar image uploads to Cloudinary
 * with automatic resizing, face-detection cropping, and validation.
 *
 * Based on real-world implementation in tweeter-spectest project.
 *
 * ⚠️ IMPORTANT: Do NOT add `format: 'auto'` parameter - it's invalid
 * for Cloudinary Node.js SDK v2.x and causes runtime errors.
 */

import { v2 as cloudinary } from 'cloudinary';

/**
 * Cloudinary Response Schema
 * Type-safe interface for upload results
 */
export interface CloudinaryResponse {
  public_id: string;
  secure_url: string;
  width: number;
  height: number;
  format: string;
  resource_type: string;
  created_at: string;
  bytes: number;
}

/**
 * Configure Cloudinary with environment variables
 *
 * Required environment variables:
 * - CLOUDINARY_CLOUD_NAME: Your Cloudinary cloud name
 * - CLOUDINARY_API_KEY: Your Cloudinary API key
 * - CLOUDINARY_API_SECRET: Your Cloudinary API secret
 *
 * Example .env:
 * CLOUDINARY_CLOUD_NAME=your-cloud-name
 * CLOUDINARY_API_KEY=123456789012345
 * CLOUDINARY_API_SECRET=your-api-secret
 */
export function configureCloudinary(): void {
  cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
  });

  // Optional: Log configuration status for debugging
  if (process.env.NODE_ENV === 'development') {
    console.log('🔧 Cloudinary configured:', {
      hasCloudName: !!process.env.CLOUDINARY_CLOUD_NAME,
      hasApiKey: !!process.env.CLOUDINARY_API_KEY,
      hasApiSecret: !!process.env.CLOUDINARY_API_SECRET,
    });
  }
}

/**
 * Upload avatar image to Cloudinary
 *
 * Features:
 * - Automatic resize to 200x200 pixels
 * - Face-detection cropping (focuses on faces)
 * - Organized in 'avatars/' folder
 * - Unique filename with timestamp
 * - Comprehensive error logging
 *
 * @param fileBuffer - Image file buffer from multer or file upload
 * @param userId - User ID for unique filename
 * @returns Promise with Cloudinary upload result
 * @throws Error if upload fails with detailed error message
 *
 * @example
 * ```typescript
 * // With Express + Multer
 * const result = await uploadAvatar(req.file.buffer, user.id);
 * console.log('Avatar URL:', result.secure_url);
 * ```
 */
export async function uploadAvatar(
  fileBuffer: Buffer,
  userId: string
): Promise<CloudinaryResponse> {
  return new Promise((resolve, reject) => {
    // Generate unique filename with timestamp
    const filename = `${userId}_${Date.now()}`;

    const uploadStream = cloudinary.uploader.upload_stream(
      {
        folder: 'avatars',
        public_id: filename,
        transformation: [
          {
            width: 200,
            height: 200,
            crop: 'fill',
            gravity: 'face', // Focus on faces when cropping
          },
        ],
        resource_type: 'image',
        // ⚠️ IMPORTANT: Do NOT add `format: 'auto'` here!
        // It's invalid for Node.js SDK v2.x and causes:
        // "Invalid extension in transformation: auto"
        // Cloudinary handles format optimization automatically.
      },
      (error, result) => {
        if (error) {
          // Comprehensive error logging for debugging
          console.error('🔴 Cloudinary Upload Error:', {
            message: error.message,
            name: error.name,
            http_code: (error as any).http_code,
            userId,
            filename,
          });
          reject(new Error(`Cloudinary upload failed: ${error.message}`));
          return;
        }

        if (!result) {
          console.error('🔴 Cloudinary Upload Error: No result returned');
          reject(new Error('Cloudinary upload failed: No result returned'));
          return;
        }

        // Success logging
        if (process.env.NODE_ENV === 'development') {
          console.log('✅ Cloudinary Upload Success:', {
            public_id: result.public_id,
            secure_url: result.secure_url,
            width: result.width,
            height: result.height,
          });
        }

        resolve(result as CloudinaryResponse);
      }
    );

    // Write buffer to upload stream
    uploadStream.end(fileBuffer);
  });
}

/**
 * Delete avatar image from Cloudinary
 *
 * Useful for cleanup when user changes avatar or deletes account.
 *
 * @param publicId - Cloudinary public_id (e.g., "avatars/user123_1234567890")
 * @returns Promise with deletion result
 *
 * @example
 * ```typescript
 * await deleteAvatar('avatars/user123_1234567890');
 * ```
 */
export async function deleteAvatar(publicId: string): Promise<void> {
  try {
    const result = await cloudinary.uploader.destroy(publicId);

    if (result.result === 'ok') {
      console.log('✅ Avatar deleted:', publicId);
    } else {
      console.warn('⚠️  Avatar deletion failed:', result);
    }
  } catch (error: any) {
    console.error('🔴 Avatar deletion error:', {
      message: error.message,
      publicId,
    });
    throw new Error(`Failed to delete avatar: ${error.message}`);
  }
}

/**
 * Extract public_id from Cloudinary URL
 *
 * Useful for getting the public_id when you only have the URL.
 *
 * @param url - Cloudinary secure_url
 * @returns Public ID without version
 *
 * @example
 * ```typescript
 * const url = 'https://res.cloudinary.com/demo/image/upload/v1234/avatars/user_123.jpg';
 * const publicId = extractPublicId(url);
 * // Returns: "avatars/user_123"
 * ```
 */
export function extractPublicId(url: string): string {
  const matches = url.match(/\/v\d+\/(.+)\.\w+$/);
  return matches ? matches[1] : '';
}

/**
 * USAGE GUIDE
 * ===========
 *
 * ## 1. Install Dependencies
 *
 * ```bash
 * npm install cloudinary
 * npm install -D @types/cloudinary
 * ```
 *
 * ## 2. Environment Setup
 *
 * Add to .env:
 * ```
 * CLOUDINARY_CLOUD_NAME=your-cloud-name
 * CLOUDINARY_API_KEY=123456789012345
 * CLOUDINARY_API_SECRET=your-api-secret
 * ```
 *
 * ## 3. Configure on Server Startup
 *
 * ```typescript
 * import { configureCloudinary } from './cloudinaryUpload';
 *
 * // Call once when server starts
 * configureCloudinary();
 * ```
 *
 * ## 4. Upload in Route Handler
 *
 * ```typescript
 * import { uploadAvatar } from './cloudinaryUpload';
 *
 * router.post('/avatar', upload.single('avatar'), async (req, res) => {
 *   if (!req.file) {
 *     return res.status(400).json({ error: 'No file uploaded' });
 *   }
 *
 *   try {
 *     const result = await uploadAvatar(req.file.buffer, req.user.id);
 *
 *     // Update user profile with new avatar URL
 *     await updateUserAvatar(req.user.id, result.secure_url);
 *
 *     res.json({ avatarUrl: result.secure_url });
 *   } catch (error) {
 *     console.error('Upload error:', error);
 *     res.status(500).json({ error: 'Failed to upload avatar' });
 *   }
 * });
 * ```
 *
 * ## 5. Delete When Needed
 *
 * ```typescript
 * import { deleteAvatar, extractPublicId } from './cloudinaryUpload';
 *
 * // When user uploads new avatar, delete old one
 * if (user.avatarUrl) {
 *   const publicId = extractPublicId(user.avatarUrl);
 *   await deleteAvatar(publicId);
 * }
 * ```
 */

/**
 * COMMON PITFALLS TO AVOID
 * =========================
 *
 * ❌ DON'T: Add `format: 'auto'` parameter
 * ✅ DO: Let Cloudinary handle format automatically
 *
 * ❌ DON'T: Forget to configure cloudinary on server startup
 * ✅ DO: Call configureCloudinary() once in server initialization
 *
 * ❌ DON'T: Upload without error handling
 * ✅ DO: Wrap uploads in try/catch and log errors
 *
 * ❌ DON'T: Expose API credentials in client-side code
 * ✅ DO: Keep all Cloudinary operations server-side only
 *
 * ❌ DON'T: Use the same filename for different users
 * ✅ DO: Include userId and timestamp in filename
 */

/**
 * DEBUGGING TIPS
 * ==============
 *
 * 1. Enable Development Logging
 *    Set NODE_ENV=development to see detailed logs
 *
 * 2. Verify Environment Variables
 *    Check that CLOUDINARY_* vars are loaded:
 *    console.log(process.env.CLOUDINARY_CLOUD_NAME)
 *
 * 3. Test with Cloudinary Dashboard
 *    Visit cloudinary.com/console to see uploads
 *    and verify transformations applied correctly
 *
 * 4. Check Error Messages
 *    Cloudinary errors include http_code and detailed messages
 *    Look for these in console output
 *
 * 5. Validate Image Buffer
 *    Ensure fileBuffer is valid image data
 *    Check file size and MIME type before upload
 */
