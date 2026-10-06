import os
import faiss
import numpy as np
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
from sentence_transformers import SentenceTransformer
from rich.console import Console
from rich.markdown import Markdown

console = Console()
console.print(Markdown("# 🤖 Offline RAG Chatbot (LaMini FLAN-T5)"))

# Set offline mode
os.environ["TRANSFORMERS_OFFLINE"] = "1"
os.environ["HF_HUB_OFFLINE"] = "1"


# Load files
def load_text_file(file_path):
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            return [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        console.print(f"[red]❌ File not found: {file_path}[/red]")
        return []


text_chunks = load_text_file("knowledge.txt")
fallback_chunks = load_text_file("fallback.txt")

if not text_chunks:
    console.print("[red]❌ knowledge.txt is empty! Add some content first.[/red]")
    exit(1)

if not fallback_chunks:
    fallback_chunks = ["I'm sorry, I couldn't find an answer. Please rephrase your question."]

# Load models
console.print("[yellow]🔄 Loading sentence embedder...[/yellow]")
embedder = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")

console.print("[yellow]🔄 Embedding knowledge base...[/yellow]")
embeddings = embedder.encode(text_chunks)
dimension = embeddings[0].shape[0]
index = faiss.IndexFlatL2(dimension)
index.add(np.array(embeddings))

console.print("[yellow]🔄 Loading LaMini FLAN-T5 model...[/yellow]")
tokenizer = AutoTokenizer.from_pretrained("models/lamini")
model = AutoModelForSeq2SeqLM.from_pretrained("models/lamini")


# Context Retrieval
def retrieve_context(query, top_k=3):
    try:
        query_vec = embedder.encode([query])
        _, indices = index.search(query_vec, top_k)
        return " ".join([text_chunks[i] for i in indices[0]])
    except Exception as e:
        console.print(f"[red]⚠️ Retrieval error: {e}[/red]")
        return ""


# Natural response generation
def generate_response_with_lamini(query, context):
    prompt = (
        f"You are a helpful assistant. Based on the context below, answer the user's question "
        f"in a full, polite, and helpful sentence.\n\n"
        f"Context: {context}\n\n"
        f"Question: {query}\n\n"
        f"Answer:"
    )
    inputs = tokenizer(prompt, return_tensors="pt", truncation=True, padding=True).input_ids
    outputs = model.generate(inputs, max_new_tokens=100)
    return tokenizer.decode(outputs[0], skip_special_tokens=True).strip()


# Unified response function
def generate_response(query):
    context = retrieve_context(query)
    if not context.strip():
        context = " ".join(fallback_chunks)
    return generate_response_with_lamini(query, context)

# Start chat
console.print(Markdown("### 💬 Start chatting below. Type `exit` to quit."))


while True:
    try:
        user_input = input("\nYou: ").strip()
        if user_input.lower() in ["exit", "quit"]:
            break
        response = generate_response(user_input)
        console.print(Markdown(f"**Bot:** {response}"))
    except KeyboardInterrupt:
        break
