from PIL import Image
import os

src = r"m:/iraq/assets/icon iraq/icon  iraq.png"
dst = r"m:/iraq/assets/icon iraq/icon_iraq_padded.png"

os.makedirs(os.path.dirname(dst), exist_ok=True)
img = Image.open(src).convert("RGBA")
w, h = img.size
margin = int(max(w, h) * 0.15)
new_w = w + 2 * margin
new_h = h + 2 * margin
new = Image.new("RGBA", (new_w, new_h), (0, 0, 0, 0))
new.paste(img, (margin, margin), img)
new.save(dst)
print('Saved padded icon to', dst)
