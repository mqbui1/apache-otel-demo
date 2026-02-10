from flask import Flask
import time

app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello from Flask!"

@app.route("/slow")
def slow():
    time.sleep(1)
    return "Slow response"
