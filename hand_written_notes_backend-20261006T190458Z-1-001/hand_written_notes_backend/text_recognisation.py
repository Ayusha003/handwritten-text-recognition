import json
import os
from datetime import datetime
from pathlib import Path

import easyocr
import cv2
import matplotlib.pyplot as plt
from textblob import TextBlob

# Initialize the reader with English language
reader = easyocr.Reader(['en'])


def correct_spelling(words):
    # Join words to form a sentence, then correct spelling
    sentence = " ".join(words)
    corrected = TextBlob(sentence).correct()
    return str(corrected)


def getText(imagePath):
    image_path = str(imagePath)  # <-- change this to your image file
    image = cv2.imread(image_path)
    print(f"Detection in progress..")
    # Run OCR
    resultText = reader.readtext(image)
    textLines = []
    for (text) in resultText:
        textLines.append(text[1])
    print(f"Detected Sentence: "+str(textLines))
    corrected_text = correct_spelling(textLines)
    print(f"Corrected Sentence: "+str(corrected_text))
    return corrected_text


def saveData(image_path,corrected_text):
    timestamp = datetime.now().strftime("%d-%m-%Y %H:%M:%S")
    output_json = os.path.join("C:\\ProgramData\\HandWritenNotesDb\\db.json")
    # Step 4: Create result entry
    entry = {
        "timeStamp": timestamp,
        "imagePath": image_path,
        "text": corrected_text
    }

    # Step 5: Append or create JSON file
    if os.path.exists(output_json):
        with open(output_json, "r+", encoding="utf-8") as f:
            data = json.load(f)
            data.append(entry)
            f.seek(0)
            json.dump(data, f, indent=4)
    else:
        with open(output_json, "w", encoding="utf-8") as f:
            json.dump([entry], f, indent=4)

    with open("knowledge.txt", "a") as f:
        f.write("\n"+str(corrected_text))
    print(f"Processed and saved into db: {entry}")


def save_text_to_downloads(filename: str, text: str):
    # Get user's Downloads folder
    downloads_path = str(Path.home() / "Downloads")

    # Ensure the Downloads directory exists
    if not os.path.exists(downloads_path):
        print("Downloads folder not found!")
        return

    # Create full file path
    file_path = os.path.join(downloads_path, filename)

    # Write the text to the file
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(text)

    print(f"Text saved successfully to: {file_path}")


# Print detected text

#     # Draw the bounding box and text
#     (top_left, top_right, bottom_right, bottom_left) = bbox
#     top_left = tuple(map(int, top_left))
#     bottom_right = tuple(map(int, bottom_right))
#
#     cv2.rectangle(image, top_left, bottom_right, (0, 255, 0), 2)
#     cv2.putText(image, text, (top_left[0], top_left[1] - 10),
#                 cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 0, 0), 2)
#
# # Display the image with annotations
# plt.imshow(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
# plt.axis('off')
# plt.show()


if __name__ == '__main__':
    save_text_to_downloads("testSave.txt", "This is test text")
