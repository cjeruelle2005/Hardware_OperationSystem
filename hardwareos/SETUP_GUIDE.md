# HardwareOS - Setup Guide for Ubuntu (4GB RAM)

## Prerequisites

This guide is optimized for developers with:
- Ubuntu Linux (any recent version)
- 4GB RAM or less
- VS Code as primary IDE
- ₱0 budget (all free tools)

---

## Step 1: Install Flutter SDK

### Download Flutter (Stable Channel)

```bash
# Navigate to home directory
cd ~

# Download Flutter SDK (stable version)
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz -O flutter.tar.xz

# Extract the archive (this may take 2-3 minutes)
tar xf flutter.tar.xz

# Remove the archive to save disk space
rm flutter.tar.xz
```

### Add Flutter to PATH

```bash
# Add Flutter to your shell configuration
echo '' >> ~/.bashrc
echo '# Flutter SDK' >> ~/.bashrc
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
echo 'export PUB_CACHE="$HOME/.pub-cache"' >> ~/.bashrc

# Apply changes immediately
source ~/.bashrc
```

### Verify Installation

```bash
# Check Flutter version
flutter --version

# Run Flutter doctor (diagnose any issues)
flutter doctor

# Accept Android licenses if prompted (optional, we're using web only)
flutter doctor --android-licenses
```

### Configure Flutter for Web

```bash
# Enable web support
flutter config --enable-web

# Disable analytics (saves resources and privacy)
flutter config --disable-analytics

# Set HTML renderer (lighter on RAM than Skia)
export FLUTTER_WEB_USE_SKIA=false
```

---

## Step 2: Install Required Tools

### Install Git (if not already installed)

```bash
sudo apt update
sudo apt install -y git
```

### Install Chrome Browser (for testing)

```bash
# Download Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# Install Chrome
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt-get install -f -y

# Clean up
rm google-chrome-stable_current_amd64.deb
```

### Install VS Code Extensions

Open VS Code and install these extensions (Command Palette → Extensions):

**Required:**
1. Dart (by Dart Code)
2. Flutter (by Dart Code)

**Recommended:**
3. GitLens — Git supercharged
4. Error Lens
5. Pubspec Assist

**DO NOT install:**
- Android Studio integrations
- Emulator extensions
- Heavy theme extensions

---

## Step 3: Setup Project

### Navigate to Project Directory

```bash
cd /workspace/hardwareos
```

### Get Dependencies

```bash
# Fetch all packages
flutter pub get

# Run code generation (for Riverpod, JSON serialization, Drift)
dart run build_runner build --delete-conflicting-outputs
```

### Verify Setup

```bash
# Check for any issues
flutter doctor

# List available devices
flutter devices
```

---

## Step 4: Run Development Server

### Start Development Server

```bash
cd /workspace/hardwareos

# Run on Chrome with HTML renderer (low RAM usage)
flutter run -d chrome --web-renderer html
```

### Alternative: Run on Specific Port

```bash
flutter run -d chrome --web-renderer html --web-port 61234
```

### Hot Reload

Once running:
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

---

## Step 5: Optimize VS Code for Low RAM

### Create/Edit `.vscode/settings.json`

The project already includes optimized settings, but you can verify:

```json
{
  "dart.previewFlutterUiGuides": false,
  "dart.previewFlutterUiGuidesCustomTracking": false,
  "dart.flutterOutline": false,
  "editor.minimap.enabled": false,
  "editor.renderWhitespace": "none",
  "workbench.list.smoothScrolling": false,
  "editor.smoothScrolling": false,
  "terminal.integrated.smoothScrolling": false,
  "git.autofetch": false,
  "files.watcherExclude": {
    "**/.git/objects/**": true,
    "**/.git/subtree-cache/**": true,
    "**/build/**": true,
    "**/.dart_tool/**": true
  }
}
```

### Additional RAM Optimization Tips

1. **Close unused tabs** in VS Code
2. **Disable unused extensions** temporarily
3. **Use Chrome DevTools** instead of Flutter DevTools during development
4. **Limit browser tabs** while running Flutter

---

## Step 6: Supabase Setup (Backend)

### Create Free Supabase Account

1. Go to https://supabase.com
2. Sign up with GitHub or email (free)
3. Create new project:
   - Name: `HardwareOS`
   - Region: **Singapore** (closest to Philippines)
   - Database password: Save securely!

### Run Database Schema

1. In Supabase Dashboard, go to **SQL Editor**
2. Copy entire contents of `database/schema.sql`
3. Paste and execute (takes ~5 seconds)
4. Verify tables were created in **Table Editor**

### Get API Credentials

1. Go to **Settings** → **API**
2. Copy:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon/public key**: `eyJhbG...`

### Configure Environment

Create a file `.env` (not committed to git):

```bash
# .env file (do not commit to git)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

Or use command-line flags when running:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

---

## Step 7: Git Workflow

### Initialize Git (already done)

```bash
cd /workspace/hardwareos
git status
```

### Create Feature Branch

```bash
# Create and switch to new branch
git checkout -b feature/auth-module

# Make changes, then commit
git add .
git commit -m "feat: implement authentication module"

# Push to GitHub
git push -u origin feature/auth-module
```

### .gitignore

The project includes a proper `.gitignore`. Never commit:
- `.env` files
- `build/` directory
- `.dart_tool/` directory
- Sensitive credentials

---

## Step 8: Build for Production

### Web Build (Production)

```bash
cd /workspace/hardwareos

# Build with HTML renderer (smaller bundle)
flutter build web --release --web-renderer html

# Output will be in: build/web/
```

### Deploy to Cloudflare Pages (Free)

```bash
# Install Wrangler CLI
npm install -g wrangler

# Login to Cloudflare
wrangler login

# Deploy
wrangler pages deploy build/web --project-name=hardwareos
```

---

## Troubleshooting

### Issue: "No devices found"

```bash
# Check Chrome installation
google-chrome --version

# If not installed, install Chrome (see Step 2)
```

### Issue: "Out of memory" during build

```bash
# Increase Dart heap size
export DART_VM_OPTIONS="--max-old-space-size=2048"

# Clean and rebuild
flutter clean
flutter pub get
flutter run -d chrome --web-renderer html
```

### Issue: Slow hot reload

```bash
# Close unnecessary applications
# Limit Chrome tabs to 2-3
# Use --profile mode for performance testing
flutter run --profile -d chrome --web-renderer html
```

### Issue: Package conflicts

```bash
# Clean pub cache
rm -rf ~/.pub-cache

# Re-fetch packages
flutter pub get
```

---

## Performance Monitoring

### Check RAM Usage

```bash
# Monitor system RAM
htop

# Or use built-in tool
free -h
```

### Flutter Build Size

```bash
# Check web build size
flutter build web --release --web-renderer html
du -sh build/web/
```

Target: < 5MB for initial load

---

## Next Steps

After setup completion:

1. ✅ Implement Authentication Module
2. ✅ Implement Inventory Module
3. ✅ Implement Procurement Module
4. ✅ Implement Sales Module
5. ✅ Implement Warehouse Module
6. ✅ Implement Dashboard
7. ✅ Implement Offline Sync
8. ✅ Deploy to Production

---

## Support Resources

- **Flutter Docs**: https://docs.flutter.dev
- **Supabase Docs**: https://supabase.com/docs
- **Riverpod Docs**: https://riverpod.dev
- **GoRouter Docs**: https://pub.dev/packages/go_router

---

**Remember:** This setup is optimized for low-resource development. As your SaaS grows and generates revenue, you can upgrade your hardware and infrastructure.

For now, focus on building a great product! 🚀
