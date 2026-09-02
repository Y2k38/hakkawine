defmodule Hakkawine.Emails.UserEmailVerificationCode do
  import Swoosh.Email
  use Phoenix.Component

  # HEEx Inline HTML Template with Inline CSS for max email client compatibility
  defp code_template(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
      </head>
      <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f4f5f7; margin: 0; padding: 40px 20px;">
        <!-- Hidden Preheader for email client list view preview -->
        <span style="display:none;font-size:1px;color:#ffffff;max-height:0px;max-width:0px;opacity:0;overflow:hidden;">
          Your Hakkawine verification code is <%= @code %>. It will expire in 5 minutes.
        </span>

        <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 520px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; border: 1px solid #e5e7eb; padding: 32px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);">
          <tr>
            <td>
              <h1 style="font-size: 22px; font-weight: 700; color: #111827; margin: 0 0 16px 0;">Verify your email address</h1>
              <p style="font-size: 15px; line-height: 24px; color: #4b5563; margin: 0 0 24px 0;">
                Thank you for registering with <strong>Hakkawine</strong>. Please use the following verification code to complete your registration:
              </p>

              <!-- Code Box Container -->
              <div style="background-color: #f3f4f6; border-radius: 8px; border: 1px dashed #d1d5db; padding: 20px; text-align: center; margin-bottom: 24px;">
                <span style="font-family: 'Courier New', Courier, monospace; font-size: 32px; font-weight: 700; letter-spacing: 6px; color: #2563eb;">
                  <%= @code %>
                </span>
              </div>

              <p style="font-size: 13px; line-height: 20px; color: #6b7280; margin: 0 0 24px 0;">
                This code is valid for <strong>5 minutes</strong>. If you did not request this code, please ignore this email.
              </p>

              <hr style="border: none; border-top: 1px solid #f3f4f6; margin: 24px 0;" />

              <!-- Footer -->
              <p style="font-size: 12px; color: #9ca3af; text-align: center; margin: 0;">
                &copy; <%= DateTime.utc_now().year %> Hakkawine Inc. All rights reserved.
              </p>
            </td>
          </tr>
        </table>
      </body>
    </html>
    """
  end

  defp heex_to_html(heex) do
    heex
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  def call(email, code) do
    new()
    |> to(email)
    |> from({"Hakkawine", "noreply@hakkawine.com"})
    |> subject("Your Hakkawine Verification Code")
    |> text_body("""
    Verify your email address

    Thank you for registering with Hakkawine. Please use the following verification code to complete your registration:

    Verification Code: #{code}

    This code is valid for 5 minutes. If you did not request this code, please ignore this email.

    © #{DateTime.utc_now().year} Hakkawine Inc.
    """)
    |> html_body(heex_to_html(code_template(%{code: code})))
  end
end
