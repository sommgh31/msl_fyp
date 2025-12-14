import torch
from torchvision.models import resnet18
from PIL import Image
from torchvision import transforms

# Load model
device = torch.device("cpu")
model = resnet18(weights=None)
model.fc = torch.nn.Linear(model.fc.in_features, 50)

state_dict = torch.load("msl_full_dataset_50_classes.pth", map_location=device)
model.load_state_dict(state_dict)
model.eval()

print("✅ Model loaded successfully!")
print(f"Output classes: {model.fc.out_features}")

# Test with an image
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.5, 0.5, 0.5], std=[0.29, 0.29, 0.29])
])

CLASSES = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    'Air', 'Awak', 'Demam', 'Dengar', 'Maaf', 'Makan', 'Masa', 'Minum',
    'Salah', 'Saya', 'Sayang Awak', 'Senyap', 'Tidur', 'Tolong'
]

# Test with a sample image
img_path = r"C:\Users\acer\pytorchtest\dataset\A\img1.jpg"  # Update this
img = Image.open(img_path).convert('RGB')
img_tensor = transform(img).unsqueeze(0)

with torch.no_grad():
    output = model(img_tensor)
    probs = torch.softmax(output, dim=1)
    conf, pred = torch.max(probs, 1)
    
    print(f"\nPrediction: {CLASSES[pred.item()]}")
    print(f"Confidence: {conf.item()*100:.2f}%")
    
    # Top 3
    top3_prob, top3_idx = torch.topk(probs, 3)
    print("\nTop 3:")
    for prob, idx in zip(top3_prob[0], top3_idx[0]):
        print(f"  {CLASSES[idx.item()]}: {prob.item()*100:.2f}%")