from flask import Flask
import time

app = Flask(__name__)

@app.route("/")
def home():
    time.sleep(0.1)
    return "Hello from backend service\n"

@app.route("/slow")
def slow():
    time.sleep(1)
    return "Slow endpoint\n"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
