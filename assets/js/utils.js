export function formatTraffic(bytes, precision = 2) {
  if (typeof bytes !== 'number' || bytes <= 0 || isNaN(bytes)) {
    return "0 GB";
  }

  const gb = bytes / (1024 * 1024 * 1024);

  if (gb >= 1024) {
    const tb = gb / 1024;
    return `${tb.toFixed(precision)} TB`;
  } else {
    return `${gb.toFixed(precision)} GB`;
  }
}

export function formatAmount(amount) {
  if (amount === null || amount === undefined) return "0";
  const num = Number(amount);
  if (isNaN(num)) return String(amount);
  return Number.isInteger(num) ? String(num) : num.toFixed(2);
}

export function formatBytesAdaptive(bytes) {
  if (bytes === 0 || isNaN(bytes)) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}