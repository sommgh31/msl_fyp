# pyright: reportAttributeAccessIssue=false
# pyright: reportArgumentType=false

from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import torch
import torch.nn as nn
from torchvision import transforms
from torchvision.models import resnet18
from PIL import Image
import io
import numpy as np
from typing import Dict
import base64
import cv2
import mediapipe as mp

app = FastAPI(title="MSL Recognition API")

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# MSL Classes (50 signs) - Exact match to your dataset
CLASSES = [
    # 26 Letters (A-Z)
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    # 11 Numbers (0-10)
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10',
    # 13 Words
    'Air', 'Awak', 'Demam', 'Dengar', 'Maaf', 'Makan', 'Minum', 
    'Salah', 'Saya', 'Senyap', 'Tidur', 'Tolong', 'Waktu'
]

print(f"Total classes: {len(CLASSES)}")

# MediaPipe Hands Setup
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(
    static_image_mode=True,
    max_num_hands=1,
    min_detection_confidence=0.5
)

# Image preprocessing
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.5, 0.5, 0.5], std=[0.29, 0.29, 0.29])
])

# Global model variable
model = None
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

def preprocess_with_mediapipe(image: Image.Image) -> Image.Image:
    """Detect and crop hand from image using MediaPipe"""
    try:
        img_array = np.array(image)
        img_rgb = cv2.cvtColor(img_array, cv2.COLOR_RGB2BGR)
        result = hands.process(img_rgb)
        
        if result.multi_hand_landmarks:
            h, w, _ = img_rgb.shape
            landmarks = result.multi_hand_landmarks[0].landmark
            
            x_min = int(min([lm.x for lm in landmarks]) * w) - 20
            y_min = int(min([lm.y for lm in landmarks]) * h) - 20
            x_max = int(max([lm.x for lm in landmarks]) * w) + 20
            y_max = int(max([lm.y for lm in landmarks]) * h) + 20
            
            x_min, y_min = max(0, x_min), max(0, y_min)
            x_max, y_max = min(w, x_max), min(h, y_max)
            
            hand_crop = image.crop((x_min, y_min, x_max, y_max))
            print("✅ Hand detected and cropped")
            return hand_crop
        
        print("⚠️ No hand detected, using full image")
        return image
        
    except Exception as e:
        print(f"❌ MediaPipe error: {e}")
        return image

def load_model(model_path: str = "final_model.pth"):
    """Load the trained ResNet18 model"""
    global model
    try:
        model = resnet18(weights=None)
        model.fc = nn.Linear(model.fc.in_features, len(CLASSES))
        
        try:
            state_dict = torch.load(model_path, map_location=device)
            model.load_state_dict(state_dict)
            print(f"✅ Loaded .pth model from {model_path}")
        except:
            try:
                from safetensors.torch import load_file
                safetensors_path = model_path.replace('.pth', '.safetensors')
                state_dict = load_file(safetensors_path)
                model.load_state_dict(state_dict)
                print(f"✅ Loaded SafeTensors model from {safetensors_path}")
            except Exception as e2:
                raise Exception(f"Could not load model: {e2}")
        
        model = model.to(device)
        model.eval()
        print(f"✅ Model ready on {device}")
        print(f"✅ Number of classes: {len(CLASSES)}")
        
    except Exception as e:
        print(f"❌ Error loading model: {e}")
        raise

@app.on_event("startup")
async def startup_event():
    """Load model on startup"""
    try:
        load_model()
    except Exception as e:
        print(f"⚠️ Warning: Could not load model on startup: {e}")

@app.get("/")
def read_root():
    return {
        "message": "MSL Recognition API with MediaPipe",
        "status": "running",
        "classes": len(CLASSES),
        "model_loaded": model is not None,
        "device": str(device)
    }

@app.get("/classes")
def get_classes():
    """Get all MSL classes"""
    return {"classes": CLASSES}

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    """Predict MSL sign from uploaded image"""
    if model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    try:
        contents = await file.read()
        image = Image.open(io.BytesIO(contents)).convert('RGB')
        image = preprocess_with_mediapipe(image)
        image_tensor = transform(image).unsqueeze(0).to(device)
        
        with torch.no_grad():
            outputs = model(image_tensor)
            probabilities = torch.softmax(outputs, dim=1)
            confidence, predicted = torch.max(probabilities, 1)
            
            top5_prob, top5_indices = torch.topk(probabilities, min(5, len(CLASSES)))
            top5_results = [
                {
                    "class": CLASSES[int(idx.item())],
                    "confidence": float(prob.item())
                }
                for prob, idx in zip(top5_prob[0], top5_indices[0])
            ]
        
        return {
            "prediction": CLASSES[int(predicted.item())],
            "confidence": float(confidence.item()),
            "top5": top5_results
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")

@app.post("/predict_base64")
async def predict_base64(data: Dict[str, str]):
    """Predict from base64 encoded image"""
    if model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    try:
        image_data = base64.b64decode(data["image"])
        image = Image.open(io.BytesIO(image_data)).convert('RGB')
        image = preprocess_with_mediapipe(image)
        image_tensor = transform(image).unsqueeze(0).to(device)
        
        with torch.no_grad():
            outputs = model(image_tensor)
            probabilities = torch.softmax(outputs, dim=1)
            confidence, predicted = torch.max(probabilities, 1)
            
            top3_prob, top3_indices = torch.topk(probabilities, min(3, len(CLASSES)))
            top3_results = [
                {
                    "class": CLASSES[int(idx.item())],
                    "confidence": float(prob.item())
                }
                for prob, idx in zip(top3_prob[0], top3_indices[0])
            ]
        
        return {
            "prediction": CLASSES[int(predicted.item())],
            "confidence": float(confidence.item()),
            "top3": top3_results
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")

@app.get("/health")
def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "model_loaded": model is not None,
        "device": str(device),
        "mediapipe": "enabled",
        "num_classes": len(CLASSES)
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)