/**
 * اجرای ایمن عملیات sync و async
 * خروجی همیشه ساختار یکنواخت دارد:
 * { success, data, error }
 *
 * @template T
 * @param {Function} operation
 * @param {string} [context='safe_execute']
 *
 * @returns {Promise<{
 *   success: boolean,
 *   data: T|null,
 *   error: Error|null
 * }>}
 */
async function safeExecute(
  operation,
  context = 'safe_execute'
) {
  if (typeof operation !== 'function') {
    return {
      success: false,
      data: null,
      error: new TypeError(
        `[${context}] operation must be a function.`
      )
    };
  }

  try {
    const result = await operation();

    return {
      success: true,
      data: result ?? null,
      error: null
    };
  } catch (error) {
    return {
      success: false,
      data: null,
      error: normalizeError(error, context)
    };
  }
}

/**
 * نرمال‌سازی خطاها به Error استاندارد
 *
 * @param {unknown} error
 * @param {string} context
 *
 * @returns {Error}
 */
function normalizeError(error, context) {
  if (error instanceof Error) {
    return error;
  }

  return new Error(
    `[${context}] ${String(error)}`
  );
}

export {
  safeExecute
};
