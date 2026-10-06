# rag_bot/rag_engine.py

import os
import faiss
import numpy as np
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
from sentence_transformers import SentenceTransformer


class RAGChatbot:
    def __init__(self, knowledge_file="knowledge.txt", fallback_file="fallback.txt", model_path="models/lamini"):
        self.knowledge_file = knowledge_file
        self.fallback_file = fallback_file
        self.model_path = model_path
        self.embedder = None
        self.index = None
        self.text_chunks = []
        self.fallback_chunks = []
        self.model = None
        self.tokenizer = None

    def load_files(self):
        def load(path):
            try:
                with open(path, "r", encoding="utf-8") as f:
                    return [line.strip() for line in f if line.strip()]
            except FileNotFoundError:
                return []

        self.text_chunks = load(self.knowledge_file)
        self.fallback_chunks = load(self.fallback_file)
        if not self.fallback_chunks:
            self.fallback_chunks = ["I'm sorry, I couldn't find an answer. Please rephrase your question."]

    def setup(self):
        print("Initialising Chatbot model")
        os.environ["TRANSFORMERS_OFFLINE"] = "1"
        os.environ["HF_HUB_OFFLINE"] = "1"

        self.load_files()

        self.embedder = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")
        embeddings = self.embedder.encode(self.text_chunks)
        dimension = embeddings[0].shape[0]
        self.index = faiss.IndexFlatL2(dimension)
        self.index.add(np.array(embeddings))

        self.tokenizer = AutoTokenizer.from_pretrained(self.model_path)
        self.model = AutoModelForSeq2SeqLM.from_pretrained(self.model_path)

    def retrieve_context(self, query, top_k=3):
        try:
            query_vec = self.embedder.encode([query])
            _, indices = self.index.search(np.array(query_vec), top_k)
            return " ".join([self.text_chunks[i] for i in indices[0]])
        except:
            return ""

    def generate(self, query):
        context = self.retrieve_context(query)
        if not context.strip():
            context = " ".join(self.fallback_chunks)

        prompt = (
            f"You are a helpful assistant. Based on the context below, answer the user's question "
            f"in a full, polite, and helpful sentence.\n\n"
            f"Context: {context}\n\n"
            f"Question: {query}\n\n"
            f"Answer:"
        )

        inputs = self.tokenizer(prompt, return_tensors="pt", truncation=True, padding=True).input_ids
        outputs = self.model.generate(inputs, max_new_tokens=100)
        return self.tokenizer.decode(outputs[0], skip_special_tokens=True).strip()
