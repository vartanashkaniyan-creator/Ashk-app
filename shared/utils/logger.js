const LEVELS = Object.freeze({
  debug: 0,
  info: 1,
  warn: 2,
  error: 3,
  silent: 4
});

let currentLevel = LEVELS.debug;

/**
 * تنظیم سطح لاگ
 *
 * @param {'debug'|'info'|'warn'|'error'|'silent'} level
 * @returns {void}
 */
function setLevel(level) {
  const hasLevel = Object.prototype.hasOwnProperty.call(
    LEVELS,
    level
  );

  if (!hasLevel) {
    console.warn(
      `[LOGGER] Invalid level: "${level}".`
    );

    return;
  }

  currentLevel = LEVELS[level];
}

/**
 * ساخت prefix استاندارد لاگ
 *
 * @param {string} level
 * @returns {string[]}
 */
function formatMessage(level) {
  return [`[${level.toUpperCase()}]`];
}

/**
 * لاگ debug
 *
 * @param {...any} args
 * @returns {void}
 */
function debug(...args) {
  if (currentLevel <= LEVELS.debug) {
    console.debug(
      ...formatMessage('debug'),
      ...args
    );
  }
}

/**
 * لاگ info
 *
 * @param {...any} args
 * @returns {void}
 */
function info(...args) {
  if (currentLevel <= LEVELS.info) {
    console.info(
      ...formatMessage('info'),
      ...args
    );
  }
}

/**
 * لاگ warn
 *
 * @param {...any} args
 * @returns {void}
 */
function warn(...args) {
  if (currentLevel <= LEVELS.warn) {
    console.warn(
      ...formatMessage('warn'),
      ...args
    );
  }
}

/**
 * لاگ error
 *
 * @param {...any} args
 * @returns {void}
 */
function error(...args) {
  if (currentLevel <= LEVELS.error) {
    console.error(
      ...formatMessage('error'),
      ...args
    );
  }
}

export {
  debug,
  info,
  warn,
  error,
  setLevel
};
