"""Handle application API."""

import logging
import os
from typing import Union

import uvicorn
from fastapi import FastAPI
from mangum import Mangum

# Configure logger
logger = logging.getLogger()
if logger.hasHandlers():
    # The Lambda environment pre-configures a handler logging to stderr. If a handler is already configured,
    # `.basicConfig` does not execute. Thus we set the level directly.
    logger.setLevel(logging.INFO)
else:
    logging.basicConfig(level=logging.INFO)

stage = os.environ.get("STAGE", None)

app = FastAPI(title="website-api")


@app.get("/")
def read_root():
    """Handle context root."""
    return {"Hello": "World"}


@app.get("/items/{item_id}")
def read_item(item_id: int, q: Union[str, None] = None):
    """Handle /items."""
    return {"item_id": item_id, "q": q}


handler = Mangum(app)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
