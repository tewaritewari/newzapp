
import requests
API_KEY = "YOUR_NEWSAPI_KEY"

def fetch_news():
    url = f"https://newsapi.org/v2/top-headlines?country=in&apiKey={API_KEY}"
    res = requests.get(url).json()
    articles = []
    for a in res.get("articles", []):
        articles.append({
            "title": a.get("title",""),
            "content": a.get("description",""),
            "url": a.get("url",""),
            "image": a.get("urlToImage",""),
            "time": a.get("publishedAt","")
        })
    return articles
