import os
from pyswip import Prolog
from PIL import Image, ImageDraw

os.makedirs("images", exist_ok=True)

# create the default image if it does not exist
default = os.path.join("images", "no_image.png")
if not os.path.exists(default):
    img = Image.new("RGB", (300, 300), "#e0e0e0")
    ImageDraw.Draw(img).text((95, 140), "No image", fill="#555555")
    img.save(default)
    print("Created images/no_image.png")

prolog = Prolog()
prolog.consult("boycott.pl")

missing = []
for r in prolog.query("image(P, F)"):
    if not os.path.exists(os.path.join("images", r["F"])):
        missing.append(r["F"])

print(f"Missing images: {len(missing)}")
for f in sorted(missing):
    print(" -", f)