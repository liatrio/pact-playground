from fastapi import FastAPI
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

app = FastAPI()

class User(BaseModel):
    id: int = Field(default=1, example=1)
    name: str = Field(default="John Doe", example="John Doe")
    email: str = Field(default="john.doe@example.com", example="john.doe@example.com")

@app.get("/user", response_model=User)
async def get_user():
    sample_user = {"id": 1, "name": "John Doe", "email": "john.doe@example.com"}
    return JSONResponse(content=sample_user)