from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
from sentence_transformers import SentenceTransformer

# EMBEDDER_DIR = "models/miniLM"
# LLM_DIR = "models/flan-t5-small"
#
# embedder = SentenceTransformer('all-MiniLM-L6-v2')
# embedder.save(EMBEDDER_DIR)

# Download and save FLAN-T5 small
# model_id = "google/flan-t5-small"
# tokenizer = AutoTokenizer.from_pretrained(model_id)
# model = AutoModelForSeq2SeqLM.from_pretrained(model_id)
# tokenizer.save_pretrained(LLM_DIR)
# model.save_pretrained(LLM_DIR)

tokenizer = AutoTokenizer.from_pretrained("MBZUAI/LaMini-Flan-T5-248M")
model = AutoModelForSeq2SeqLM.from_pretrained("MBZUAI/LaMini-Flan-T5-248M")
tokenizer.save_pretrained("models/lamini")
model.save_pretrained("models/lamini")

print("✅ All models downloaded and saved locally.")
