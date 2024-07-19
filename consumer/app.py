import logging
import requests
from flask import Flask, Response

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class User:
    def __init__(self, user_id, name, email):
        self.user_id = user_id
        self.name = name
        self.email = email

    @classmethod
    def from_dict(cls, data):
        return cls(
            user_id=data.get("user_id", None),
            name=data.get("name", None),
            email=data.get("email", None),
        )


class UserApiClient:
    def __init__(self, base_url):
        self.base_url = base_url

    def get_user(self):
        try:
            response = requests.get(f"{self.base_url}/user", timeout=5)
            if response.status_code == 200:
                user_data = response.json()
                return User.from_dict(user_data)
            logger.error("Backend service error: %s", response.status_code)
            return None
        except requests.exceptions.RequestException as e:
            logger.error("Request to backend service failed: %s", e)
            return None


# Example usage within a Flask route
@app.route("/")
def hello_user():
    user_api_client = UserApiClient("http://127.0.0.1:8082")
    user = user_api_client.get_user()
    if user:
        return f"Hello, {user.name}!"
    return Response("Error contacting backend service!", status=503)


@app.route("/liveness")
def liveness():
    return "OK"


@app.route("/readiness")
def readiness():
    # Implement readiness check logic here
    return "OK"


if __name__ == "__main__":
    app.run(debug=True)
