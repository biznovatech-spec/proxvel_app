import sys
import os
from PIL import Image

def process_icon():
    source_path = r"C:\Users\danie\Downloads\PROXVEL LOGO.jpg"
    target_path = r"C:\Users\danie\Documents\Proyectos\PROXVEL\proxvel_app\assets\icons\app_icon.png"
    
    if not os.path.exists(source_path):
        print(f"Error: Source image not found at {source_path}")
        sys.exit(1)
        
    try:
        # Load the original image
        img = Image.open(source_path)
        img = img.convert("RGBA")
        
        # Calculate aspect ratio
        w, h = img.size
        
        # We will resize the image so that the SMALLEST dimension is 1024,
        # then crop the center to 1024x1024. This ensures the image fills the 
        # entire canvas and leaves no square borders.
        ratio = max(1024/w, 1024/h)
        new_w = int(w * ratio)
        new_h = int(h * ratio)
        
        img_resized = img.resize((new_w, new_h), Image.Resampling.LANCZOS)
        
        # Crop center
        left = (new_w - 1024) / 2
        top = (new_h - 1024) / 2
        right = (new_w + 1024) / 2
        bottom = (new_h + 1024) / 2
        
        img_cropped = img_resized.crop((left, top, right, bottom))
        
        # Save as PNG
        img_cropped.save(target_path, "PNG")
        print("Success")
    except Exception as e:
        print(f"Failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    process_icon()
