# ===============================
# MSL Full Dataset Training (51 Classes)
# A-Z (26), 0-10 (11), Words (14)
# ===============================
import os
import cv2
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms
from torchvision.models import resnet18, ResNet18_Weights
from sklearn.model_selection import StratifiedShuffleSplit
from PIL import Image
import numpy as np
try:
    import mediapipe as mp
    mp_hands = mp.solutions.hands  # type: ignore
except AttributeError:
    from mediapipe.python.solutions import hands as mp_hands  # type: ignore
from tqdm import tqdm

# ======================================
# CONFIGURATION
# ======================================
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Using device: {device}")

# Get paths
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
DATASET_PATH = os.path.join(SCRIPT_DIR, "dataset")
MODELS_OUTPUT_PATH = os.path.join(SCRIPT_DIR, "models")

os.makedirs(MODELS_OUTPUT_PATH, exist_ok=True)

print(f"Dataset path: {DATASET_PATH}")
print(f"Models output: {MODELS_OUTPUT_PATH}")

# All 51 classes - UPDATED TO INCLUDE "Sayang Awak"
ALLOWED_CLASSES = [
    # 26 Letters (A-Z)
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    # 11 Numbers (0-10)
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10',
    # 14 Words (alphabetically sorted, including "Sayang Awak")
    'Air', 'Awak', 'Demam', 'Dengar', 'Maaf', 'Makan', 'Minum',
    'Salah', 'Saya', 'Sayang Awak', 'Senyap', 'Tidur', 'Tolong', 'Waktu'
]

NUM_CLASSES = len(ALLOWED_CLASSES)
BATCH_SIZE = 32
NUM_EPOCHS = 20
LEARNING_RATE = 0.001

print(f"\n{'='*60}")
print(f"Training Configuration:")
print(f"  Total Classes: {NUM_CLASSES}")
print(f"  - Letters: 26 (A-Z)")
print(f"  - Numbers: 11 (0-10)")
print(f"  - Words: 14 (includes 'Sayang Awak')")
print(f"  Batch Size: {BATCH_SIZE}")
print(f"  Epochs: {NUM_EPOCHS}")
print(f"  Learning Rate: {LEARNING_RATE}")
print(f"{'='*60}\n")

# ======================================
# MEDIAPIPE SETUP
# ======================================
hands = mp_hands.Hands(  # type: ignore
    static_image_mode=True,
    max_num_hands=1,
    min_detection_confidence=0.5
)

# ======================================
# DATASET CLASS
# ======================================
class MSLDataset(Dataset):
    def __init__(self, path, classes, transform=None, use_mediapipe=True):
        self.path = path
        self.classes = classes
        self.transform = transform
        self.use_mediapipe = use_mediapipe
        self.images_path, self.targets = [], []

        print("\n📂 Loading dataset...")
        
        for label, cls_name in enumerate(self.classes):
            cls_path = os.path.join(path, cls_name)
            
            if not os.path.exists(cls_path):
                print(f"  ⚠️  Missing: {cls_name}")
                continue
                
            count = 0
            for filename in os.listdir(cls_path):
                if filename.lower().endswith(('.jpg', '.jpeg', '.png')):
                    self.images_path.append(os.path.join(cls_path, filename))
                    self.targets.append(label)
                    count += 1
            
            if count > 0:
                print(f"  ✅ {cls_name:15s}: {count:4d} images")
            else:
                print(f"  ⚠️  {cls_name:15s}: NO IMAGES FOUND")

        print(f"\n📊 Total images loaded: {len(self.targets)}")

    def crop_hand(self, img):
        """Crop hand using MediaPipe"""
        try:
            img_rgb = cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)
            result = hands.process(img_rgb)  # type: ignore
            
            if result.multi_hand_landmarks:  # type: ignore
                h, w, _ = img_rgb.shape
                landmarks = result.multi_hand_landmarks[0].landmark  # type: ignore
                
                x_min = int(min([lm.x for lm in landmarks]) * w) - 20
                y_min = int(min([lm.y for lm in landmarks]) * h) - 20
                x_max = int(max([lm.x for lm in landmarks]) * w) + 20
                y_max = int(max([lm.y for lm in landmarks]) * h) + 20
                
                x_min, y_min = max(0, x_min), max(0, y_min)
                x_max, y_max = min(w, x_max), min(h, y_max)
                
                hand_crop = img.crop((x_min, y_min, x_max, y_max))
                return hand_crop
        except:
            pass
        
        return img

    def __len__(self):
        return len(self.targets)

    def __getitem__(self, idx):
        img_path = self.images_path[idx]
        img = Image.open(img_path).convert("RGB")
        
        if self.use_mediapipe:
            img = self.crop_hand(img)
        
        label = self.targets[idx]
        
        if self.transform:
            img = self.transform(img)
        
        return img, label

# ======================================
# TRANSFORMS
# ======================================
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.5, 0.5, 0.5], std=[0.29, 0.29, 0.29])
])

# ======================================
# LOAD DATASET
# ======================================
print("\n" + "="*60)
print("STEP 1: Loading Dataset")
print("="*60)

dataset = MSLDataset(DATASET_PATH, ALLOWED_CLASSES, transform, use_mediapipe=True)

if len(dataset) == 0:
    print("\n❌ ERROR: No images found!")
    print(f"\nExpected dataset structure:")
    print(f"  {DATASET_PATH}/")
    print(f"    ├── A/")
    print(f"    ├── B/")
    print(f"    ├── ...")
    print(f"    ├── Z/")
    print(f"    ├── 0/")
    print(f"    ├── 1/")
    print(f"    ├── ...")
    print(f"    ├── 10/")
    print(f"    ├── Air/")
    print(f"    ├── Awak/")
    print(f"    ├── Sayang Awak/  ← NEW!")
    print(f"    └── ...")
    exit()

# Verify all classes are present
missing_classes = []
for cls in ALLOWED_CLASSES:
    cls_path = os.path.join(DATASET_PATH, cls)
    if not os.path.exists(cls_path):
        missing_classes.append(cls)

if missing_classes:
    print(f"\n⚠️  WARNING: Missing {len(missing_classes)} class folders:")
    for cls in missing_classes:
        print(f"  - {cls}")
    print("\nTraining will continue with available classes only.")

# ======================================
# TRAIN/TEST SPLIT
# ======================================
print("\n" + "="*60)
print("STEP 2: Splitting Dataset (80% train, 20% test)")
print("="*60)

splitter = StratifiedShuffleSplit(n_splits=1, test_size=0.2, random_state=42)
train_idx, test_idx = next(splitter.split(np.zeros(len(dataset.targets)), dataset.targets))

train_loader = DataLoader(
    dataset,
    batch_size=BATCH_SIZE,
    sampler=torch.utils.data.SubsetRandomSampler(train_idx),
    num_workers=0
)

test_loader = DataLoader(
    dataset,
    batch_size=BATCH_SIZE,
    sampler=torch.utils.data.SubsetRandomSampler(test_idx),
    num_workers=0
)

print(f"✅ Training samples: {len(train_idx)}")
print(f"✅ Testing samples: {len(test_idx)}")

# ======================================
# MODEL SETUP
# ======================================
print("\n" + "="*60)
print("STEP 3: Initializing Model")
print("="*60)

model = resnet18(weights=ResNet18_Weights.IMAGENET1K_V1)
model.fc = nn.Linear(model.fc.in_features, NUM_CLASSES)
model = model.to(device)

criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=LEARNING_RATE)

print(f"✅ Model: ResNet18 (pretrained on ImageNet)")
print(f"✅ Output classes: {NUM_CLASSES}")
print(f"✅ Loss function: CrossEntropyLoss")
print(f"✅ Optimizer: Adam (lr={LEARNING_RATE})")

# ======================================
# TRAINING FUNCTIONS
# ======================================
def train_one_epoch(epoch):
    model.train()
    running_loss = 0.0
    correct = 0
    total = 0
    
    pbar = tqdm(train_loader, desc=f"Epoch {epoch+1}/{NUM_EPOCHS}")
    
    for inputs, labels in pbar:
        inputs, labels = inputs.to(device), labels.to(device)
        
        optimizer.zero_grad()
        outputs = model(inputs)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()
        
        running_loss += loss.item()
        _, predicted = torch.max(outputs, 1)
        total += labels.size(0)
        correct += (predicted == labels).sum().item()
        
        pbar.set_postfix({
            'loss': f'{running_loss/(pbar.n+1):.3f}',
            'acc': f'{100*correct/total:.2f}%'
        })
    
    epoch_loss = running_loss / len(train_loader)
    epoch_acc = 100 * correct / total
    
    return epoch_loss, epoch_acc

def evaluate():
    model.eval()
    correct = 0
    total = 0
    running_loss = 0.0
    
    with torch.no_grad():
        for inputs, labels in test_loader:
            inputs, labels = inputs.to(device), labels.to(device)
            outputs = model(inputs)
            loss = criterion(outputs, labels)
            
            running_loss += loss.item()
            _, predicted = torch.max(outputs, 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()
    
    test_loss = running_loss / len(test_loader)
    test_acc = 100 * correct / total
    
    return test_loss, test_acc

# ======================================
# TRAINING LOOP
# ======================================
print("\n" + "="*60)
print("STEP 4: Training Model")
print("="*60)
print(f"Estimated time: ~{NUM_EPOCHS * 2} minutes\n")

best_acc = 0.0
best_model_state = None

for epoch in range(NUM_EPOCHS):
    train_loss, train_acc = train_one_epoch(epoch)
    test_loss, test_acc = evaluate()
    
    print(f"\n📊 Epoch {epoch+1}/{NUM_EPOCHS}:")
    print(f"  Train → Loss: {train_loss:.4f} | Acc: {train_acc:.2f}%")
    print(f"  Test  → Loss: {test_loss:.4f} | Acc: {test_acc:.2f}%")
    
    if test_acc > best_acc:
        best_acc = test_acc
        best_model_state = model.state_dict().copy()
        print(f"  ⭐ New best accuracy: {best_acc:.2f}%")
    
    print("-" * 60)

# ======================================
# SAVE MODEL
# ======================================
print("\n" + "="*60)
print("STEP 5: Saving Model")
print("="*60)

if best_model_state:
    model.load_state_dict(best_model_state)

print(f"\n🎉 Training Complete!")
print(f"  Best Test Accuracy: {best_acc:.2f}%")

# Save in models folder
model_pth_path = os.path.join(MODELS_OUTPUT_PATH, "msl_51_classes.pth")
torch.save(model.state_dict(), model_pth_path)
print(f"\n✅ Saved: {model_pth_path}")

# Save SafeTensors
try:
    from safetensors.torch import save_file
    model_st_path = os.path.join(MODELS_OUTPUT_PATH, "msl_51_classes.safetensors")
    save_file(model.state_dict(), model_st_path)
    print(f"✅ Saved: {model_st_path}")
except ImportError:
    print("⚠️  SafeTensors not installed (optional)")

# Copy to backend
backend_path = os.path.join(PROJECT_ROOT, "backend", "final_model.pth")
try:
    import shutil
    shutil.copy(model_pth_path, backend_path)
    print(f"✅ Copied to backend: {backend_path}")
except Exception as e:
    print(f"⚠️  Manual copy needed:")
    print(f"   From: {model_pth_path}")
    print(f"   To: {backend_path}")

hands.close()

