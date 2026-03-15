# Platform Playbooks

## Instagram (posts/reels)

1. Attempt `web_fetch` first.
2. If only shell page returns, switch to `browser` with `profile="user"`.
3. Ask user to approve browser attach prompt if required.
4. Open reel/post URL, take snapshot, read caption/comments/onscreen text.
5. If video cannot be parsed fully, ask for direct upload or screen recording.

## X / Twitter threads

1. Try `web_fetch`.
2. If blocked by dynamic rendering, use `browser` snapshot.
3. Capture thread sequence and quoted posts before summarizing.

## TikTok

1. Try `web_fetch`.
2. Use `browser` for in-page caption/hashtags/overlay text.
3. If playback blocked by region/login, request file upload.

## YouTube

1. Use `web_fetch` for metadata/transcript snippets when available.
2. If transcript unavailable and deep analysis needed, request video file or transcript text.

## LinkedIn

1. Public posts: `web_fetch` first.
2. Private/network-gated posts: `browser` with user profile login.

## Reliability Rule

When content is incomplete, label summary as "partial" and list exactly what was accessible.
