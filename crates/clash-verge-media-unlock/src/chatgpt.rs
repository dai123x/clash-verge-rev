use reqwest::{Client, StatusCode};

use crate::utils::{get_status_and_text, get_trace_location};

use super::UnlockItem;

pub(crate) const CHATGPT_WEB_NAME: &str = "ChatGPT Web";

pub(super) async fn check_chatgpt(client: &Client) -> UnlockItem {
    let region = get_trace_location(client, "https://chat.openai.com/cdn-cgi/trace")
        .await
        .map(|loc| UnlockItem::region_label(&loc));

    // api.openai.com sits behind Cloudflare: an exit IP OpenAI refuses gets a 403
    // challenge page whose body must not be read as a successful compliance check.
    let web_status =
        match get_status_and_text(client, "https://api.openai.com/compliance/cookie_requirements").await {
            Some((StatusCode::FORBIDDEN | StatusCode::UNAVAILABLE_FOR_LEGAL_REASONS, _)) => "No",
            Some((status, body)) if status.is_success() => {
                if body.to_ascii_lowercase().contains("unsupported_country") {
                    "Unsupported Country/Region"
                } else {
                    "Yes"
                }
            }
            _ => "Failed",
        };

    UnlockItem::checked(CHATGPT_WEB_NAME, web_status, region)
}
