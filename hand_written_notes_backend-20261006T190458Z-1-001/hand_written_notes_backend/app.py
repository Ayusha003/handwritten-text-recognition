from flask import Flask, request, jsonify
from flask_cors import CORS

from routes.chatbot_routes import chatbot_bp
from routes.system_routes import system_bp

app = Flask(__name__)
CORS(app)  # Important to allow Flutter to access Flask server

app.register_blueprint(system_bp)
app.register_blueprint(chatbot_bp)

if __name__ == '__main__':
    app.run(debug=False)
