
from fastapi import FastAPI
import schedule, time, threading
from fetcher import fetch_news
from summarizer import summarize
from database import news_db

app = FastAPI()

def update_news():
    global news_db
    raw = fetch_news()
    updated = []
    for n in raw:
        n["summary"] = summarize(n["content"])
        updated.append(n)
    news_db = updated
    print("News updated")

def scheduler():
    schedule.every(1).hours.do(update_news)
    while True:
        schedule.run_pending()
        time.sleep(60)

@app.on_event("startup")
def start():
    update_news()
    threading.Thread(target=scheduler).start()

@app.get("/news")
def get_news():
    return news_db[:50]
