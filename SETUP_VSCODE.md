# HardwareOS - VS Code Development Setup Guide

## 🚀 QUICK START: Running in VS Code

### Prerequisites Check
Before running, ensure you have Flutter installed on Ubuntu.

---

## 📦 STEP 1: Install Flutter (If Not Installed)

```bash
# Navigate to home directory
cd ~

# Download Flutter SDK (stable channel)
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz

# Extract Flutter
tar xf flutter_linux_3.24.0-stable.tar.xz

# Move to development folder
mkdir -p ~/development
mv flutter ~/development/

# Add Flutter to PATH (add this to ~/.bashrc)
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
flutter --version
```

---

## ⚙️ STEP 2: Install Required Tools

```bash
# Update package list
sudo apt update

# Install essential tools
sudo apt install -y curl git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev

# Install Chrome for Flutter Web (optional but recommended)
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt-get install -f -y
rm google-chrome-stable_current_amd64.deb
```

---

## 🏗️ STEP 3: Setup Project Dependencies

```bash
# Navigate to project
cd /workspace

# Get Flutter dependencies
flutter pub get

# Verify setup
flutter doctor
```

---

## ▶️ STEP 4: Run the Application

### Option A: Run in Chrome (Recommended for Web Development)

**Using Terminal:**
```bash
cd /workspace
flutter run -d chrome --web-renderer html
```

**Using VS Code:**
1. Press `F5` or go to `Run > Start Debugging`
2. Select "Chrome" from device list
3. App will launch in Chrome

### Option B: Run in Web Server Mode

```bash
cd /workspace
flutter run -d web-server --web-hostname=localhost --web-port=8080 --web-renderer html
```

Access at: `http://localhost:8080`

### Option C: Build for Production Web

```bash
cd /workspace
flutter build web --release --web-renderer html
```

Output will be in `/workspace/build/web/`

---

## 🔧 VS Code Extensions Required

Install these extensions in VS Code:

1. **Flutter** (by Dart Code)
2. **Dart** (by Dart Code)
3. **Pubspec Assist** (optional, for managing dependencies)

**To install:**
- Press `Ctrl+Shift+X` in VS Code
- Search for each extension and click "Install"

---

## 🎯 Low-RAM Optimization Settings

The `.vscode/settings.json` is already configured for 4GB RAM:

- Minimap disabled
- Generated files excluded from search
- Hot reload on manual
- DevTools disabled by default

**Additional tips:**
- Close unnecessary tabs
- Use terminal instead of integrated tools when possible
- Restart VS Code if it becomes slow

---

## 🐛 Debugging

### Enable Debug Mode

```bash
flutter run -d chrome --web-renderer html --debug
```

### Hot Reload

- Press `r` in terminal during development
- Or press `Ctrl+S` with hot reload enabled

### Hot Restart

- Press `R` in terminal
- Or use VS Code restart button

### View Logs

- Use `print()` statements in code
- View in VS Code Debug Console (`Ctrl+Shift+Y`)
- Or view in Chrome DevTools (`F12` → Console)

---

## 📁 Important Commands

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter clean` | Clean build artifacts |
| `flutter pub run build_runner build --delete-conflicting-outputs` | Generate code (Drift, etc.) |
| `flutter analyze` | Check for code issues |
| `flutter test` | Run tests |
| `flutter build web --release` | Build production web app |

---

## 🌐 Connect to Supabase

Before running, configure your Supabase credentials:

1. Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

2. Edit `.env` with your Supabase details:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

---

## 🚨 Troubleshooting

### "Flutter command not found"
```bash
export PATH="$HOME/development/flutter/bin:$PATH"
```

### Port already in use
```bash
# Kill process on port 8080
sudo lsof -ti:8080 | xargs kill -9
```

### Build fails due to memory
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run --web-renderer html
```

### Chrome not launching
```bash
# Set Chrome executable path
export CHROME_EXECUTABLE=/usr/bin/google-chrome
```

---

## 📊 Development Workflow

1. **Start coding** in VS Code
2. **Save file** (`Ctrl+S`) - triggers hot reload
3. **Test features** in Chrome
4. **Check console** for errors
5. **Commit changes** regularly

---

## 🎉 You're Ready!

Your HardwareOS development environment is optimized for low-RAM Ubuntu systems.

**Next Step:** Run `flutter run -d chrome --web-renderer html` and start building!

---

## 📞 Quick Reference

- **Flutter Docs**: https://docs.flutter.dev
- **Supabase Docs**: https://supabase.com/docs
- **Riverpod Docs**: https://riverpod.dev
- **Drift Docs**: https://drift.simonbinder.eu
