import hashlib
import os
import time
from urllib.parse import parse_qs, urlencode, urlparse, urlunparse

from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, RedirectResponse
import requests

app = FastAPI(title="Mock Easy Payment Service")

def epay_sign(params: dict, secret_key: str) -> str:
    """Standard Easy Payment MD5 signature calculation."""
    # Filter empty values, nulls, and existing signature fields
    filtered = {
        k: v
        for k, v in params.items()
        if v != "" and v is not None and k not in ["sign", "sign_type"]
    }
    # Sort parameters alphabetically by key (ASCII order)
    sorted_keys = sorted(filtered.keys())
    # Concatenate into key1=value1&key2=value2 format
    query_string = "&".join([f"{k}={filtered[k]}" for k in sorted_keys])
    # Append the secret key and calculate MD5
    sign_str = query_string + secret_key
    return hashlib.md5(sign_str.encode("utf-8")).hexdigest()

@app.get("/submit.php", response_class=HTMLResponse)
async def submit(request: Request):
    """Simulates the payment gateway checkout page."""
    params = dict(request.query_params)
    query_str = str(request.query_params)

    out_trade_no = params.get("out_trade_no", "N/A")
    money = params.get("money", "0.00")

    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <title>Mock Epay Checkout</title>
    </head>
    <body style="font-family: system-ui, -apple-system, sans-serif; padding: 40px; max-width: 500px; margin: 0 auto; color: #111827;">
      <h2 style="margin-bottom: 20px;">⚡ Mock Payment Cashier</h2>
      <div style="background: #f3f4f6; padding: 16px; border-radius: 8px; margin-bottom: 24px;">
        <p style="margin: 6px 0;"><b>Merchant Order No.:</b> {out_trade_no}</p>
        <p style="margin: 6px 0;"><b>Amount:</b> ${money}</p>
      </div>
      <a href="/pay_success?{query_str}" style="text-decoration: none;">
        <button style="width: 100%; padding: 12px; background: #10B981; color: white; border: none; border-radius: 6px; font-size: 16px; font-weight: 600; cursor: pointer;">
          ✅ Simulate Successful Payment
        </button>
      </a>
    </body>
    </html>
    """
    return HTMLResponse(content=html_content)

@app.get("/pay_success")
async def pay_success(request: Request):
    """Handles successful payment simulation, async webhook callback, and client redirect."""
    params = dict(request.query_params)
    secret_key = os.getenv("EPAY_KEY", "mock_key")

    notify_params = {
        "pid": params.get("pid", "1000"),
        "trade_no": f"MOCK_{int(time.time() * 1000)}",
        "out_trade_no": params.get("out_trade_no", ""),
        "type": params.get("type", "alipay"),
        "name": params.get("name", "Test Item"),
        "money": params.get("money", "0.00"),
        "trade_status": "TRADE_SUCCESS",
    }

    # Generate MD5 signature
    sign = epay_sign(notify_params, secret_key)
    notify_params["sign"] = sign
    notify_params["sign_type"] = "MD5"

    # 1. Asynchronous webhook notification (notify_url)
    notify_url = params.get("notify_url")
    if notify_url:
        try:
            requests.post(notify_url, data=notify_params, timeout=5)
            print(f"[Mock Epay] Webhook delivered successfully to: {notify_url}")
        except Exception as e:
            print(f"[Mock Epay] Failed to deliver webhook: {e}")

    # 2. Redirect back to client return URL (return_url)
    return_url = params.get("return_url", "/")
    parsed_url = urlparse(return_url)
    existing_query = parse_qs(parsed_url.query)

    # Flatten existing query parameters and merge payload
    merged_query = {k: v[0] for k, v in existing_query.items()}
    merged_query.update(notify_params)

    new_query_str = urlencode(merged_query)
    final_return_url = urlunparse(
        (
            parsed_url.scheme,
            parsed_url.netloc,
            parsed_url.path,
            parsed_url.params,
            new_query_str,
            parsed_url.fragment,
        )
    )

    return RedirectResponse(url=final_return_url, status_code=302)

if __name__ == "__main__":
    import uvicorn

    port = int(os.getenv("PORT", 3001))
    print(f"🚀 [Mock Epay] Listening on: http://localhost:{port}")
    uvicorn.run(app, host="127.0.0.1", port=port)