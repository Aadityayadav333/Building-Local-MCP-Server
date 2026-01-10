print("MCP SERVER STARTED")


import json
import os
import httpx
from dotenv import load_dotenv
from fastmcp import FastMCP
from utils import clean_html_to_text

load_dotenv()
print("SERPER_API_KEY:", os.getenv("SERPER_API_KEY"))


mcp = FastMCP("docs")

SERPER_URL = "https://google.serper.dev/search"


async def search_web(query: str) -> dict:
    payload = json.dumps({"q": query, "num": 5})

    headers = {
        "X-API-KEY": os.getenv("SERPER_API_KEY"),
        "Content-Type": "application/json",
    }

    async with httpx.AsyncClient() as client:
        response = await client.post(SERPER_URL, headers=headers, data=payload, timeout=30)
        response.raise_for_status()
        return response.json()


async def fetch_url(url: str):
    async with httpx.AsyncClient() as client:
        response = await client.get(url, timeout=30)

    return clean_html_to_text(response.text)


docs_urls = {
    "langchain": "https://python.langchain.com/docs",
    "llama-index": "https://docs.llamaindex.ai/en/stable",
    "openai": "https://platform.openai.com/docs",
    "uv": "https://docs.astral.sh/uv",
}


@mcp.tool()
async def get_docs(query: str, library: str):
    """
    Search the latest docs for the given query and library.
    """

    if library not in docs_urls:
        raise ValueError(f"Library '{library}' not supported")

    search_query = f"site:{docs_urls[library]} {query}"

    results = await search_web(search_query)

    #debugging :
    print("Search query:", search_query)
    print("Serper response keys:", results.keys())

    organic = results.get("organic", [])

    if not organic:
        fallback_query = query
        results = await search_web(fallback_query)
        organic = results.get("organic",[])

    parts = []

    for item in organic[:2]:
        link = item.get("link", "")
        if not link:
            continue

        page_text = await fetch_url(link)
        page_text = page_text[:3000] #limit set

        parts.append(f"SOURCE: {link}\n{page_text}")

    return "\n\n".join(parts)


def main():
    mcp.run(transport="stdio")


if __name__ == "__main__":
    main()
