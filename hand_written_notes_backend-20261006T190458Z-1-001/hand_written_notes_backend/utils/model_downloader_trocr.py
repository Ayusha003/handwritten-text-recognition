from transformers import TrOCRProcessor, VisionEncoderDecoderModel
import torch
from PIL import Image

# Set your desired offline cache path
LOCAL_CACHE_DIR = "../models/trocr_local"
# EMBEDDER_DIR = "models/miniLM"
# LLM_DIR = "models/flan-t5-small"
#
# embedder = SentenceTransformer('all-MiniLM-L6-v2')
# embedder.save(EMBEDDER_DIR)
# Load processor and model from Hugging Face
processor = TrOCRProcessor.from_pretrained("microsoft/trocr-small-stage1", cache_dir=LOCAL_CACHE_DIR)
model = VisionEncoderDecoderModel.from_pretrained("microsoft/trocr-small-stage1", cache_dir=LOCAL_CACHE_DIR)

# Save the processor and model to disk
processor.save_pretrained(LOCAL_CACHE_DIR)
model.save_pretrained(LOCAL_CACHE_DIR)