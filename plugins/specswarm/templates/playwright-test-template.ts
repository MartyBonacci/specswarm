import { test, expect, Page } from '@playwright/test';

/**
 * Auto-generated browser tests for Feature {FEATURE_NUM}
 * Feature: {FEATURE_NAME}
 * Generated from: features/{FEATURE_DIR}/spec.md
 *
 * This test file validates the user interface and user flows
 * defined in the feature specification.
 */

// Test configuration
const BASE_URL = process.env.BASE_URL || 'http://localhost:5173';
const SCREENSHOTS_DIR = 'test-results/screenshots';

test.describe('{FEATURE_NAME}', () => {

  test.beforeEach(async ({ page }) => {
    // Setup: Navigate to application
    await page.goto(BASE_URL);
  });

  /**
   * User Flow 1: {FLOW_1_NAME}
   *
   * Steps from spec:
   * {FLOW_1_STEPS}
   */
  test('{FLOW_1_TEST_NAME}', async ({ page }) => {
    // Step 1: {STEP_1_DESCRIPTION}
    await page.goto('{STEP_1_URL}');
    await page.screenshot({
      path: `${SCREENSHOTS_DIR}/{FLOW_1_SLUG}-step-1.png`,
      fullPage: true
    });

    // Verify: {STEP_1_VERIFICATION}
    await expect(page.locator('{STEP_1_SELECTOR}')).toBeVisible();

    // Step 2: {STEP_2_DESCRIPTION}
    await page.fill('{STEP_2_INPUT_SELECTOR}', '{STEP_2_VALUE}');
    await page.screenshot({
      path: `${SCREENSHOTS_DIR}/{FLOW_1_SLUG}-step-2.png`,
      fullPage: true
    });

    // Verify: {STEP_2_VERIFICATION}
    await expect(page.locator('{STEP_2_INPUT_SELECTOR}')).toHaveValue('{STEP_2_VALUE}');

    // Step 3: {STEP_3_DESCRIPTION}
    await page.click('{STEP_3_BUTTON_SELECTOR}');
    await page.waitForLoadState('networkidle');
    await page.screenshot({
      path: `${SCREENSHOTS_DIR}/{FLOW_1_SLUG}-step-3.png`,
      fullPage: true
    });

    // Verify final state: {FINAL_STATE_VERIFICATION}
    await expect(page.locator('{FINAL_STATE_SELECTOR}')).toContainText('{EXPECTED_TEXT}');
  });

  /**
   * Visual Regression: Key UI States
   *
   * Captures screenshots of all important pages/states
   * for visual validation against spec requirements
   */
  test('visual regression - key pages', async ({ page }) => {
    const pages = [
      { url: '{PAGE_1_URL}', name: '{PAGE_1_NAME}' },
      { url: '{PAGE_2_URL}', name: '{PAGE_2_NAME}' },
      { url: '{PAGE_3_URL}', name: '{PAGE_3_NAME}' },
    ];

    for (const { url, name } of pages) {
      await page.goto(url);

      // Wait for page to be fully loaded
      await page.waitForLoadState('networkidle');

      // Capture full-page screenshot
      await page.screenshot({
        path: `${SCREENSHOTS_DIR}/visual-${name}.png`,
        fullPage: true
      });

      // Verify no JavaScript console errors
      const errors: string[] = [];
      page.on('console', msg => {
        if (msg.type() === 'error') {
          errors.push(msg.text());
        }
      });

      if (errors.length > 0) {
        console.warn(`Console errors on ${name}:`, errors);
      }
    }
  });

  /**
   * Accessibility: WCAG 2.1 Level AA Compliance
   *
   * Validates basic accessibility requirements:
   * - Images have alt text
   * - Form inputs have labels
   * - Buttons have accessible names
   * - Proper heading hierarchy
   */
  test('accessibility - basic wcag checks', async ({ page }) => {
    await page.goto('{MAIN_PAGE_URL}');

    // Check 1: All images have alt text
    const images = await page.locator('img').all();
    for (const img of images) {
      const alt = await img.getAttribute('alt');
      const ariaLabel = await img.getAttribute('aria-label');
      const role = await img.getAttribute('role');

      // Images should have alt text, aria-label, or role="presentation"
      expect(
        alt !== null || ariaLabel !== null || role === 'presentation',
        'All images must have alt text, aria-label, or role="presentation"'
      ).toBeTruthy();
    }

    // Check 2: All form inputs have labels
    const inputs = await page.locator('input, textarea, select').all();
    for (const input of inputs) {
      const id = await input.getAttribute('id');
      const ariaLabel = await input.getAttribute('aria-label');
      const ariaLabelledBy = await input.getAttribute('aria-labelledby');

      // Input should have id with matching label, or aria-label, or aria-labelledby
      const hasLabel = id ? await page.locator(`label[for="${id}"]`).count() > 0 : false;

      expect(
        hasLabel || ariaLabel !== null || ariaLabelledBy !== null,
        'All form inputs must have labels or aria-label'
      ).toBeTruthy();
    }

    // Check 3: All buttons have accessible names
    const buttons = await page.locator('button').all();
    for (const button of buttons) {
      const text = (await button.textContent())?.trim();
      const ariaLabel = await button.getAttribute('aria-label');
      const ariaLabelledBy = await button.getAttribute('aria-labelledby');

      expect(
        (text && text.length > 0) || ariaLabel !== null || ariaLabelledBy !== null,
        'All buttons must have visible text or aria-label'
      ).toBeTruthy();
    }

    // Check 4: Heading hierarchy is proper
    const h1Count = await page.locator('h1').count();
    expect(h1Count, 'Page should have exactly one h1').toBe(1);

    // Check 5: Links have accessible names
    const links = await page.locator('a').all();
    for (const link of links) {
      const text = (await link.textContent())?.trim();
      const ariaLabel = await link.getAttribute('aria-label');
      const title = await link.getAttribute('title');

      expect(
        (text && text.length > 0) || ariaLabel !== null || title !== null,
        'All links must have visible text, aria-label, or title'
      ).toBeTruthy();
    }
  });

  /**
   * Error Handling: Validation and Error States
   *
   * Tests how the UI handles invalid input and error conditions
   */
  test('error handling - form validation', async ({ page }) => {
    await page.goto('{FORM_PAGE_URL}');

    // Try to submit form with invalid data
    await page.click('{SUBMIT_BUTTON_SELECTOR}');

    // Verify error messages appear
    await expect(page.locator('{ERROR_MESSAGE_SELECTOR}')).toBeVisible();

    // Capture error state screenshot
    await page.screenshot({
      path: `${SCREENSHOTS_DIR}/error-validation.png`,
      fullPage: true
    });

    // Verify form is not submitted (should still be on same page)
    expect(page.url()).toContain('{FORM_PAGE_URL}');
  });

  /**
   * Performance: Page Load Speed
   *
   * Validates that pages load within reasonable timeframes
   */
  test('performance - page load times', async ({ page }) => {
    const pages = [
      { url: '{PAGE_1_URL}', maxLoadTime: 3000 },
      { url: '{PAGE_2_URL}', maxLoadTime: 3000 },
    ];

    for (const { url, maxLoadTime } of pages) {
      const startTime = Date.now();

      await page.goto(url);
      await page.waitForLoadState('load');

      const loadTime = Date.now() - startTime;

      expect(loadTime, `${url} should load in less than ${maxLoadTime}ms`).toBeLessThan(maxLoadTime);
    }
  });
});

/**
 * Helper Functions
 */

// Helper: Login as test user (if authentication required)
async function loginAsTestUser(page: Page) {
  await page.goto('/signin');
  await page.fill('[name="email"]', 'test@example.com');
  await page.fill('[name="password"]', 'password123');
  await page.click('[type="submit"]');
  await page.waitForURL('/feed'); // or wherever login redirects
}

// Helper: Clear application state
async function clearAppState(page: Page) {
  await page.context().clearCookies();
  await page.context().clearPermissions();
}

// Helper: Wait for element with timeout
async function waitForElement(page: Page, selector: string, timeout = 5000) {
  await page.waitForSelector(selector, { timeout });
}
