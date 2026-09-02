defmodule Hakkawine.Emails.UserEmailResetPassword do
  import Swoosh.Email
  use Phoenix.Component

  defp reset_password_template(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
      </head>
      <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f4f5f7; margin: 0; padding: 40px 20px;">
        <!-- Hidden Preheader for email client inbox snippet text -->
        <span style="display:none;font-size:1px;color:#ffffff;max-height:0px;max-width:0px;opacity:0;overflow:hidden;">
          Reset your Hakkawine account password. This link is valid for a limited time.
        </span>

        <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 520px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; border: 1px solid #e5e7eb; padding: 32px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);">
          <tr>
            <td>
              <h1 style="font-size: 22px; font-weight: 700; color: #111827; margin: 0 0 16px 0;">Reset Your Password</h1>

              <p style="font-size: 15px; line-height: 24px; color: #4b5563; margin: 0 0 20px 0;">
                We received a request to reset the password for your <strong>Hakkawine</strong> account. Click the button below to set up a new password:
              </p>

              <!-- Action Button -->
              <div style="margin: 28px 0; text-align: center;">
                <a href={@reset_url} target="_blank" style="background-color: #2563eb; color: #ffffff; padding: 12px 28px; text-decoration: none; border-radius: 8px; display: inline-block; font-weight: 600; font-size: 15px; box-shadow: 0 2px 4px rgba(37, 99, 235, 0.2);">
                  Reset Password
                </a>
              </div>

              <!-- Backup Text Link -->
              <p style="font-size: 13px; line-height: 20px; color: #6b7280; margin: 0 0 8px 0;">
                If the button above doesn't work, copy and paste the following link into your browser:
              </p>
              <p style="font-size: 13px; line-height: 20px; word-break: break-all; margin: 0 0 24px 0;">
                <a href={@reset_url} style="color: #2563eb; text-decoration: underline;"><%= @reset_url %></a>
              </p>

              <!-- Security Warning -->
              <p style="font-size: 13px; line-height: 20px; color: #9ca3af; margin: 0 0 24px 0;">
                If you did not request a password reset, please ignore this email or contact support if you have concerns. Your password will remain unchanged.
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

  def call(email, token) do
    base_url = HakkawineWeb.Endpoint.url()
    reset_url = "#{base_url}/auth/reset_password?token=#{token}"

    new()
    |> to(email)
    |> from({"Hakkawine", "noreply@hakkawine.com"})
    |> subject("Reset Your Hakkawine Password")
    |> text_body("""
    Reset Your Password

    We received a request to reset the password for your Hakkawine account.

    To set up a new password, please visit the following link:
    #{reset_url}

    If you did not request a password reset, please ignore this email. Your password will remain unchanged.

    © #{DateTime.utc_now().year} Hakkawine Inc.
    """)
    |> html_body(heex_to_html(reset_password_template(%{reset_url: reset_url})))
  end
end
