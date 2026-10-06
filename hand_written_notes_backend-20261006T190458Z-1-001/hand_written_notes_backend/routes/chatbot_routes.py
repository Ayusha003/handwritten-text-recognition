import json

from flask import Blueprint, request, jsonify

from RAGChatbot import RAGChatbot

chatbot_bp = Blueprint('chatbot', __name__, url_prefix='/chatbot')

rag_bot = RAGChatbot()
rag_bot.setup()


@chatbot_bp.route('/chat', methods=['POST'])
def chat():
    data = request.json
    # query = data.get('query', '')
    query = data['query']
    if not query:
        return jsonify({"error": "No query provided"}), 400

    response = rag_bot.generate(query)
    return jsonify({"success": True, "data": response})