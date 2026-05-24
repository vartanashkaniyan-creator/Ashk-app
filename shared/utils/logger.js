// shared/utils/logger.js

/**
 * Logger سبک و مستقل پروژه
 * - بدون DI
 * - بدون وابستگی خارجی
 * - مناسب MVP
 * - Fail-soft برای config اشتباه
 */

const LEVELS = Object.freeze({
  debug: 0,
  info: 1,
  warn: 2,
  error: 3,
  silent: 4
});

const LEVEL_NAMES = Object.freeze({
  0: 'debug',
  1: 'info',
  2: 'warn',
  3: 'error',
  4: 'silent'
});

let currentLevel = LEVELS.debug;

/**
 * تنظیم سطح لاگ
 *
 * @param {'debug'|'info'|'warn'|'error'|'silent'} level
 * @returns {void}
 */
function setLevel(level) {
  if (!Object.hasOwn(LEVELS, level)) {
    console.warn(
      `[LOGGER] Invalid level: "${level}". Keeping "${getCurrentLevelName()}".`
    );

    return;
  }

  currentLevel = LEVELS[level];
}

/**
 * دریافت نام سطح فعلی لاگ
 *
 * @returns {string}
 */
function getCurrentLevelName() {
  return LEVEL_NAMES[currentLevel];
}

/**
 * ساخت پیام استاندارد لاگ
 *
 * @param {string} level
 * @returns {string[]}
 */
function formatMessage(level) {
  return [
    `[${level.toUpperCase()}]`,
    new Date().toISOString()
  ];
}

/**
 * @param {...any} args
 * @returns {void}
 */
function debug(...args) {
  if (currentLevel <= LEVELS.debug) {
    console.debug(...formatMessage('debug'), ...args);
  }
}

/**
 * @param {...any} args
 * @returns {void}
 */
function info(...args) {
  if (currentLevel <= LEVELS.info) {
    console.info(...formatMessage('info'), ...args);
  }
}

/**
 * @param {...any} args
 * @returns {void}
 */
function warn(...args) {
  if (currentLevel <= LEVELS.warn) {
    console.warn(...formatMessage('warn'), ...args);
  }
}

/**
 * @param {...any} args
 * @returns {void}
 */
function error(...args) {
  if (currentLevel <= LEVELS.error) {
    console.error(...formatMessage('error'), ...args);
  }
}

export {
  debug,
  info,
  warn,
  error,
  setLevel,
  getCurrentLevelName
};
