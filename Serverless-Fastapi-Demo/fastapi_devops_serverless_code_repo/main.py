import json
import os
from typing import Literal, Optional
from uuid import uuid4
from fastapi import FastAPI, HTTPException
import random
from fastapi.encoders import jsonable_encoder
from pydantic import BaseModel
from mangum import Mangum
from fastapi import FastAPI, Response
from fastapi.responses import HTMLResponse

class Book(BaseModel):
    name: str
    genre: str
    price: float
    book_id: str


BOOKS_FILE = "books.json"
BOOKS = []

if os.path.exists(BOOKS_FILE):
    with open(BOOKS_FILE, "r") as f:
        BOOKS = json.load(f)

app = FastAPI()
handler = Mangum(app)


@app.get("/")
async def root():
    return HTMLResponse(content="<span style='color:red; font-weight:bold; font-size: 50px;'>Welcome to my bookstore app!</span>")


@app.get("/random-book", response_model=Book)
async def random_book():
    with open(BOOKS_FILE, "r") as f:
        books = json.load(f)

    # Select a random book
    random_book = random.choice(books)

    return random_book


@app.get("/list-books")
async def list_books(response: Response):
    with open(BOOKS_FILE, "r") as f:
        books = json.load(f)

    # Convert each book to a string and join them with newline characters
    books_str = "\n".join(json.dumps(book) for book in books)

    # Set content type and return the response
    response.headers["Content-Type"] = "application/json"
    return Response(content=books_str.encode(), media_type="application/json")


@app.get("/book_by_index/{index}")
async def book_by_index(index: int):
    if index < len(BOOKS):
        return BOOKS[index]
    else:
        raise HTTPException(404, f"Book index {index} out of range ({len(BOOKS)}).")


@app.post("/add-book")
async def add_book(book: Book):
    book.book_id = uuid4().hex
    json_book = jsonable_encoder(book)
    BOOKS.append(json_book)

    with open(BOOKS_FILE, "w") as f:
        json.dump(BOOKS, f)

    return {"book_id": book.book_id}


@app.get("/get-book")
async def get_book(book_id: str):
    for book in BOOKS:
        if book.book_id == book_id:
            return book

    raise HTTPException(404, f"Book ID {book_id} not found in database.")
