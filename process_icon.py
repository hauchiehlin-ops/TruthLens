import sys
try:
    from PIL import Image
except ImportError:
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow"])
    from PIL import Image

image_path = "/Users/barretlin/.gemini/antigravity/brain/e4ee63e3-9033-42a2-aabc-fd36c50ca4bd/logo_concept_omnitrace_1788244593889.jpg"
img = Image.open(image_path)
print(f"Original size: {img.size}")

# AI generated icons are usually 1024x1024 with a smaller rounded square inside.
# Let's crop it tightly to the inner square. 
# We'll just take a 768x768 square from the center, or whatever fits best.
# Let's find the bounding box of the non-gray pixels, or just do a center crop of the dark area.

# Actually, the user wants it as the official app icon. 
# We can just use the center 80% of the image.
width, height = img.size
crop_ratio = 0.72 # Adjust this depending on how much padding the AI added
left = (width - width * crop_ratio) / 2
top = (height - height * crop_ratio) / 2
right = (width + width * crop_ratio) / 2
bottom = (height + height * crop_ratio) / 2

img_cropped = img.crop((left, top, right, bottom))
# Save it as PNG
import os
os.makedirs("assets", exist_ok=True)
img_cropped.save("assets/icon.png")
print("Cropped and saved to assets/icon.png")
