use reqwest::{Client, StatusCode};

use crate::utils::get_status_and_text;

use super::UnlockItem;

pub(crate) const CLAUDE_NAME: &str = "Claude";

const BLOCKED_CODES: &[&str] = &["AF", "BY", "CN", "CU", "HK", "IR", "KP", "MO", "RU", "SY"];

pub(super) async fn check_claude(client: &Client) -> UnlockItem {
    // claude.ai fronts its edge with Cloudflare: a refused exit IP gets a 403 page
    // without any loc= line, which is a verifiable block rather than a probe failure.
    let Some((status, body)) = get_status_and_text(client, "https://claude.ai/cdn-cgi/trace").await
    else {
        return UnlockItem::checked(CLAUDE_NAME, "Failed", None);
    };

    if status == StatusCode::FORBIDDEN {
        return UnlockItem::checked(CLAUDE_NAME, "No", None);
    }

    let Some(code) = body
        .lines()
        .find_map(|line| line.strip_prefix("loc="))
        .map(|code| code.trim().to_ascii_uppercase())
    else {
        return UnlockItem::checked(CLAUDE_NAME, "Failed", None);
    };

    let verdict = if BLOCKED_CODES.contains(&code.as_str()) {
        "No"
    } else {
        "Yes"
    };

    UnlockItem::checked_region(CLAUDE_NAME, verdict, &code)
}
