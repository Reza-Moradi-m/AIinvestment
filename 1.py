import os
import google.generativeai as genai
from dotenv import load_dotenv

# Load API key from .env file
load_dotenv()
API_KEY = os.getenv("GOOGLE_API_KEY")

if not API_KEY:
    raise ValueError("ERROR: Missing GOOGLE_API_KEY in .env file")

genai.configure(api_key=API_KEY)

def clean_response(text):
    """ Cleans AI response to match Erlang's expected format. """
    lines = text.strip().split("\n")
    formatted_lines = []

    for line in lines:
        if line.startswith("**") and line.endswith("**"):
            formatted_lines.append(line.strip("**") + ":")
        elif line.startswith("- Source:"):
            formatted_lines.append(line.replace("- Source:", "Source:"))
        else:
            formatted_lines.append(line)

    return "\n".join(formatted_lines)

def fetch_investment_news():
    """ Fetches latest investment news from Gemini AI formatted for Erlang. """
    prompt = """
    Provide the latest investment news for Bitcoin, Stocks, Gold, and Real Estate.
    Follow this exact format, keeping details realistic:

    Bitcoin: "Bitcoin remains steady around $24,500, with a slight dip in trading volume."
    Source: CoinDesk (https://www.coindesk.com/markets)
    Risk: Medium
    Volatility: High
    Trend: Neutral
    Market Condition: Stable
    Sector: Cryptocurrency
    Historical Performance: Up 3% last month

    Stocks: "US stocks close higher, Nasdaq leads gains."
    Source: CNBC (https://www.cnbc.com/market-update)
    Risk: Low
    Volatility: Medium
    Trend: Bullish
    Market Condition: Strong
    Sector: Technology
    Historical Performance: Up 7% last month

    Gold: "Gold prices edge higher on geopolitical tensions."
    Source: Reuters (https://www.reuters.com/markets/commodities)
    Risk: Low
    Volatility: Low
    Trend: Bullish
    Market Condition: Safe Haven
    Sector: Commodities
    Historical Performance: Up 5% last month

    Real Estate: "US home sales fall 7.7% as mortgage rates soar."
    Source: Bloomberg (https://www.bloomberg.com/news/articles)
    Risk: High
    Volatility: Medium
    Trend: Bearish
    Market Condition: Weak
    Sector: Housing
    Historical Performance: Down 4% last month
    """
    
    response = genai.GenerativeModel("gemini-pro").generate_content(prompt)

    if not response or not response.text:
        raise ValueError("ERROR: No response from Gemini API")

    return clean_response(response.text.strip())

def save_news_to_file():
    """ Saves news data to a text file with UTF-8 encoding """
    news_data = fetch_investment_news()
    with open("investment_news.txt", "w", encoding="utf-8") as f:
        f.write(news_data + "\n")

save_news_to_file()
print("News saved successfully to investment_news.txt")