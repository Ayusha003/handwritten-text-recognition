import json

from flask import Blueprint, request, jsonify

from text_recognisation import getText, saveData, save_text_to_downloads

system_bp = Blueprint('system', __name__, url_prefix='/system')


@system_bp.route('/fetchText', methods=['POST'])
async def fetchText():
    try:
        print("fetchText called")
        requestData = request.json

        if not requestData:
            return jsonify({"success": False, "error": "Empty or invalid JSON @ fetchText"}), 400

        imagePath = requestData.get("imgPath")
        print("Details: imgPath: " + str(imagePath))
        if not imagePath:
            return jsonify({"error": "Missing 'imgPath'"}), 400

        results = getText(imagePath)

        result = {"success": True, "data": results}

        return jsonify(result), 200

    except Exception as e:
        print("Exception in fetchText:", e)
        return jsonify({"error": "Internal server error"}), 500


@system_bp.route('/saveText', methods=['POST'])
async def saveText():
    try:
        print("saveText called")
        requestData = request.json

        if not requestData:
            return jsonify({"success": False, "error": "Empty or invalid JSON @ saveText"}), 400

        imagePath = requestData.get("imgPath")
        text = requestData.get("text")
        print("Details: imgPath: " + str(imagePath)+", text:"+str(text))
        if not imagePath or not text:
            return jsonify({"error": "Missing 'imgPath' or 'text"}), 400

        results = saveData(imagePath,text)

        result = {"success": True, "data": results}

        return jsonify(result), 200

    except Exception as e:
        print("Exception in saveText:", e)
        return jsonify({"error": "Internal server error"}), 500


@system_bp.route('/downloadText', methods=['POST'])
async def downloadText():
    try:
        print("downloadText called")
        requestData = request.json

        if not requestData:
            return jsonify({"success": False, "error": "Empty or invalid JSON @ saveText"}), 400

        text = requestData.get("text")
        fileName = requestData.get("fileName")
        print("Details: fileName: " + str(fileName)+", text:"+str(text))
        if not fileName or not text:
            return jsonify({"error": "Missing 'fileName' or 'text"}), 400

        results = save_text_to_downloads(fileName,text)

        result = {"success": True, "data": "File downloaded"}

        return jsonify(result), 200

    except Exception as e:
        print("Exception in downloadText:", e)
        return jsonify({"error": "Internal server error"}), 500