from urllib.parse import quote


def placeholder_poster(title: str, category: str, color: str = "38bdf8") -> str:
    short_title = title if len(title) <= 30 else title[:27] + "..."
    encoded_title = quote(short_title)
    encoded_category = quote(category)
    return f"https://placehold.co/300x450/0f172a/{color}/png?text=[{encoded_category}]%0A%0A{encoded_title}"
