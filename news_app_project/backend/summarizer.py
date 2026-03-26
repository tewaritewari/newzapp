
def summarize(text):
    if not text:
        return "No summary available"
    return text[:100] + "..."
