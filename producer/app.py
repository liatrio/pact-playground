from random import randint
import logging

from flask import Flask, jsonify

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def fib(n):
    if n <= 1:
        return n
    else:
        return fib(n - 1) + fib(n - 2)


@app.route("/")
def hello():
    return "Hello, World!"


@app.route("/liveness")
def liveness():
    return "OK"


@app.route("/readiness")
def readiness():
    return "OK"


@app.route("/fib")
def stress_cpu():
    n = randint(1, 30)
    result = fib(n)
    return f"Fibonacci number at position {n} is {result}"


@app.route("/user")
def get_user():
    sample_user = {"id": 1, "name": "John Doe", "email": "john.doe@example.com"}
    return jsonify(sample_user)
