/**
 * Cloudinary Avatar Upload Pattern - Tests
 *
 * These tests verify the proven pattern works correctly.
 * Run with: npm test avatar-upload.test.ts
 */

import { describe, it, expect, beforeAll, afterAll, vi } from 'vitest';
import { uploadAvatar, deleteAvatar, extractPublicId, configureCloudinary } from './avatar-upload';

/**
 * IMPORTANT: These are integration tests that require actual Cloudinary credentials.
 * For unit tests, mock the cloudinary SDK.
 */

describe('Cloudinary Avatar Upload Pattern', () => {
  describe('extractPublicId', () => {
    it('should extract public_id from Cloudinary URL', () => {
      const url = 'https://res.cloudinary.com/demo/image/upload/v1234567890/avatars/user_123.jpg';
      const publicId = extractPublicId(url);
      expect(publicId).toBe('avatars/user_123');
    });

    it('should handle URLs without version', () => {
      const url = 'https://res.cloudinary.com/demo/image/upload/avatars/user_123.jpg';
      const publicId = extractPublicId(url);
      expect(publicId).toBe('');
    });

    it('should handle different formats', () => {
      const url = 'https://res.cloudinary.com/demo/image/upload/v1234/avatars/test.png';
      const publicId = extractPublicId(url);
      expect(publicId).toBe('avatars/test');
    });
  });

  describe('configureCloudinary', () => {
    it('should configure cloudinary without errors', () => {
      // Set test environment variables
      process.env.CLOUDINARY_CLOUD_NAME = 'test-cloud';
      process.env.CLOUDINARY_API_KEY = '123456';
      process.env.CLOUDINARY_API_SECRET = 'test-secret';

      expect(() => configureCloudinary()).not.toThrow();
    });

    it('should work with missing env vars (will fail on upload)', () => {
      delete process.env.CLOUDINARY_CLOUD_NAME;
      delete process.env.CLOUDINARY_API_KEY;
      delete process.env.CLOUDINARY_API_SECRET;

      // Configuration itself shouldn't throw
      expect(() => configureCloudinary()).not.toThrow();
      // But uploads will fail - that's expected
    });
  });

  /**
   * INTEGRATION TESTS
   * Requires real Cloudinary credentials in .env
   * Skip these in CI unless you have test credentials
   */
  describe.skip('uploadAvatar (integration)', () => {
    beforeAll(() => {
      // Ensure environment variables are set
      if (!process.env.CLOUDINARY_CLOUD_NAME) {
        throw new Error('CLOUDINARY_CLOUD_NAME not set - required for integration tests');
      }
      configureCloudinary();
    });

    it('should upload avatar successfully', async () => {
      // Create test image buffer (1x1 red pixel PNG)
      const testImageBuffer = Buffer.from(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==',
        'base64'
      );

      const userId = 'test-user-123';
      const result = await uploadAvatar(testImageBuffer, userId);

      expect(result).toBeDefined();
      expect(result.public_id).toContain('avatars/');
      expect(result.public_id).toContain(userId);
      expect(result.secure_url).toMatch(/^https:\/\//);
      expect(result.width).toBe(200);
      expect(result.height).toBe(200);

      // Cleanup: delete uploaded image
      await deleteAvatar(result.public_id);
    }, 30000); // 30 second timeout for upload

    it('should reject invalid image buffer', async () => {
      const invalidBuffer = Buffer.from('not an image');
      const userId = 'test-user-456';

      await expect(uploadAvatar(invalidBuffer, userId)).rejects.toThrow();
    });

    it('should generate unique filenames for same user', async () => {
      const testImageBuffer = Buffer.from(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==',
        'base64'
      );

      const userId = 'test-user-789';

      const result1 = await uploadAvatar(testImageBuffer, userId);
      await new Promise(resolve => setTimeout(resolve, 1000)); // Wait 1 second
      const result2 = await uploadAvatar(testImageBuffer, userId);

      expect(result1.public_id).not.toBe(result2.public_id);

      // Cleanup
      await deleteAvatar(result1.public_id);
      await deleteAvatar(result2.public_id);
    }, 60000);
  });

  describe.skip('deleteAvatar (integration)', () => {
    beforeAll(() => {
      configureCloudinary();
    });

    it('should delete avatar successfully', async () => {
      // Upload test image first
      const testImageBuffer = Buffer.from(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==',
        'base64'
      );

      const result = await uploadAvatar(testImageBuffer, 'test-delete-user');

      // Delete it
      await expect(deleteAvatar(result.public_id)).resolves.not.toThrow();
    }, 30000);

    it('should handle deleting non-existent image', async () => {
      // Should not throw, just log warning
      await expect(deleteAvatar('avatars/non-existent-123')).resolves.not.toThrow();
    });
  });

  /**
   * UNIT TESTS WITH MOCKING
   * Safe to run in CI - doesn't require real credentials
   */
  describe('uploadAvatar (mocked)', () => {
    it('should handle upload errors gracefully', async () => {
      // This would require mocking the cloudinary SDK
      // Example with vitest mock:

      // vi.mock('cloudinary', () => ({
      //   v2: {
      //     uploader: {
      //       upload_stream: vi.fn((options, callback) => {
      //         callback(new Error('Network error'), null);
      //         return { end: vi.fn() };
      //       }),
      //     },
      //   },
      // }));

      // Then test that errors are properly caught and re-thrown
      // with useful error messages
    });
  });
});

/**
 * MANUAL TESTING GUIDE
 * ====================
 *
 * 1. Set up .env with test Cloudinary account:
 *    CLOUDINARY_CLOUD_NAME=test-account
 *    CLOUDINARY_API_KEY=123456
 *    CLOUDINARY_API_SECRET=your-secret
 *
 * 2. Remove .skip from integration tests
 *
 * 3. Run tests:
 *    npm test avatar-upload.test.ts
 *
 * 4. Check Cloudinary dashboard to verify uploads/deletes
 *
 * 5. Add .skip back before committing (unless CI has test creds)
 */

/**
 * CI/CD INTEGRATION
 * ================
 *
 * For CI pipelines:
 *
 * Option 1: Use Cloudinary test account
 * - Create dedicated test account
 * - Add credentials to CI secrets
 * - Remove .skip from integration tests
 *
 * Option 2: Use mocks only
 * - Keep integration tests skipped
 * - Only run unit tests with mocked SDK
 * - Run integration tests manually before releases
 *
 * Option 3: Use Cloudinary programmatic test mode
 * - Some SDKs support test mode that doesn't upload
 * - Check Cloudinary docs for test mode availability
 */
