# 🎨 Cara Membuat Icon Aplikasi "Catat Saku"

## 📋 Kebutuhan Icon

Anda perlu membuat 2 file icon:

1. **`app_icon.png`** - Icon utama (1024x1024 px)
2. **`app_icon_foreground.png`** - Icon untuk Android adaptive (1024x1024 px, transparent background)

---

## 🎯 Opsi 1: Buat Icon Online (Termudah)

### **Menggunakan Icon Generator:**

1. **Buka:** https://icon.kitchen atau https://romannurik.github.io/AndroidAssetStudio/
2. **Pilih:** "Image" sebagai source
3. **Upload/Buat:**
   - Text: "CS" atau "💰" 
   - Background color: `#5D5FEF` (ungu)
   - Foreground: Putih
4. **Download** hasil generate
5. **Rename:**
   - Main icon → `app_icon.png`
   - Foreground → `app_icon_foreground.png`
6. **Paste** ke folder ini (`assets/icon/`)

---

## 🎯 Opsi 2: Buat di Canva/Figma

### **Design Specs:**

**Icon Design:**
```
Size: 1024x1024 px
Background: #5D5FEF (Ungu)
Text: "CS" atau "💰"
Font: Bold, White color
Center aligned
```

### **Steps:**

1. **Buka Canva** (www.canva.com)
2. **Custom size:** 1024x1024 px
3. **Background:** Ungu #5D5FEF
4. **Add text:** "CS" atau emoji 💰
5. **Style:** Bold, white, center
6. **Download as PNG**
7. **Save as:** `app_icon.png`

**For Foreground (Android Adaptive):**
1. Same design
2. Background: **Transparent**
3. Only icon/text visible
4. Download as PNG
5. Save as: `app_icon_foreground.png`

---

## 🎯 Opsi 3: Gunakan Template Sederhana

### **Buat file HTML ini dan buka di browser:**

```html
<!DOCTYPE html>
<html>
<head>
    <title>Catat Saku Icon Generator</title>
</head>
<body>
    <canvas id="canvas" width="1024" height="1024"></canvas>
    <br>
    <button onclick="download('app_icon.png')">Download Main Icon</button>
    <button onclick="downloadTransparent('app_icon_foreground.png')">Download Foreground</button>
    
    <script>
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        
        // Main icon with background
        ctx.fillStyle = '#5D5FEF';
        ctx.fillRect(0, 0, 1024, 1024);
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 400px Arial';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText('CS', 512, 512);
        
        function download(filename) {
            const link = document.createElement('a');
            link.download = filename;
            link.href = canvas.toDataURL();
            link.click();
        }
        
        function downloadTransparent(filename) {
            ctx.clearRect(0, 0, 1024, 1024);
            ctx.fillStyle = '#FFFFFF';
            ctx.font = 'bold 400px Arial';
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            ctx.fillText('CS', 512, 512);
            
            const link = document.createElement('a');
            link.download = filename;
            link.href = canvas.toDataURL();
            link.click();
            
            // Redraw main icon
            ctx.fillStyle = '#5D5FEF';
            ctx.fillRect(0, 0, 1024, 1024);
            ctx.fillStyle = '#FFFFFF';
            ctx.fillText('CS', 512, 512);
        }
    </script>
</body>
</html>
```

Save as `icon_generator.html`, buka di browser, klik button untuk download!

---

## 🎯 Opsi 4: Gunakan Icon Yang Sudah Jadi

Download icon dari:
- **Flaticon:** www.flaticon.com (search "wallet" atau "money")
- **Icons8:** icons8.com (search "wallet icon")
- **Free:** Pastikan license free for commercial use

Edit warna menjadi ungu (#5D5FEF) menggunakan:
- Photoshop
- GIMP (free)
- Photopea.com (online, free)

---

## 📦 Setelah Icon Siap

### **1. Pastikan File Ada:**
```
assets/icon/
  ├── app_icon.png (1024x1024)
  └── app_icon_foreground.png (1024x1024, transparent)
```

### **2. Install Dependencies:**
```bash
flutter pub get
```

### **3. Generate Icons:**
```bash
flutter pub run flutter_launcher_icons
```

### **4. Rebuild App:**
```bash
flutter clean
flutter pub get
flutter run
```

---

## ✅ Checklist

- [ ] Buat/download `app_icon.png` (1024x1024)
- [ ] Buat/download `app_icon_foreground.png` (1024x1024, transparent)
- [ ] Paste kedua file ke `assets/icon/`
- [ ] Run `flutter pub get`
- [ ] Run `flutter pub run flutter_launcher_icons`
- [ ] Run `flutter clean && flutter run`
- [ ] Cek icon di home screen device

---

## 🎨 Design Suggestions

**Ide 1: Simple Text**
```
Background: #5D5FEF
Text: "CS" (Catat Saku)
Color: White
Style: Bold, Rounded
```

**Ide 2: Emoji**
```
Background: #5D5FEF
Icon: 💰 (money bag)
atau: 📝 (note)
atau: 💵 (dollar)
```

**Ide 3: Custom Icon**
```
Background: #5D5FEF
Icon: Wallet outline (white)
atau: Notebook + pen (white)
Style: Minimalist, modern
```

---

## 🚀 Quick Start (Tercepat)

1. Buka: https://icon.kitchen
2. Text: "CS"
3. Background: #5D5FEF
4. Download
5. Rename & paste ke sini
6. `flutter pub run flutter_launcher_icons`
7. Done! 🎉

---

Selamat mencoba! 🚀
