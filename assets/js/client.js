// TODO: separate app.js to client.js for heex static website

import "phoenix_html"
import Alpine from "../vendor/alpine.min.js"

window.Alpine = Alpine
Alpine.start()

import { formatTraffic, formatAmount, formatBytesAdaptive } from "./utils.js";

window.HakkawineJS = {
  formatTraffic,
  formatAmount,
  formatBytesAdaptive
};