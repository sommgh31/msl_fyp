# MSL Recognition Backend

FastAPI backend server for Malaysian Sign Language recognition using ResNet18 and MediaPipe.

## Setup

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Prepare the Model

The backend requires a trained model file (`final_model.pth` or `final_model.safetensors`) in the backend directory.

**Option A: Copy from training directory (if model already exists)**

```bash
# From project root
cp training/models/msl_full_dataset_50_classes.pth backend/final_model.pth
```

**Option B: Train the model first**

```bash
cd ../training
python train_full_dataset.py
```

The training script will automatically copy the model to the backend directory.

### 3. Start the Server

```bash
python main.py
```

Or using uvicorn directly:

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

The server will start on `http://0.0.0.0:8000`

## API Endpoints

- `GET /` - API information
- `GET /health` - Health check (returns model status)
- `GET /classes` - Get all available sign classes
- `POST /predict` - Predict from image file (multipart/form-data)
- `POST /predict_base64` - Predict from base64 encoded image (JSON)

## Testing

Test the health endpoint:

```bash
curl http://localhost:8000/health
```

Test prediction with an image:

```bash
curl -X POST "http://localhost:8000/predict" -F "file=@path/to/image.jpg"
```

## Troubleshooting

### Model Not Loading

- Ensure `final_model.pth` or `final_model.safetensors` exists in the backend directory
- Check that the model file is not corrupted
- Verify the model was trained with the same number of classes (50)

### Port Already in Use

Change the port in `main.py`:

```python
uvicorn.run(app, host="0.0.0.0", port=8001)  # Use different port
```

### CORS Issues

CORS is already configured to allow all origins. If you need to restrict it, modify the CORS middleware in `main.py`.

