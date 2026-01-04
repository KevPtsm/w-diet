#!/bin/bash
# Setup script to connect w-diet to GitHub
# Run this AFTER Xcode installation is complete

echo "🚀 Setting up GitHub repository for w-diet..."

# Check if Xcode license is agreed
if ! xcodebuild -version &> /dev/null; then
    echo "⚠️  Xcode license not agreed yet."
    echo "Please run: sudo xcodebuild -license"
    echo "Then run this script again."
    exit 1
fi

# Add GitHub remote
echo "📦 Adding GitHub remote..."
git remote add origin https://github.com/KevPtsm/w-diet.git

# Check if remote was added
if git remote -v | grep -q "origin"; then
    echo "✅ GitHub remote added successfully!"
    git remote -v
else
    echo "❌ Failed to add remote"
    exit 1
fi

# Commit .gitignore
echo "📝 Committing .gitignore..."
git add .gitignore
git commit -m "chore: add Xcode .gitignore"

# Push to GitHub
echo "⬆️  Pushing to GitHub..."
git branch -M main
git push -u origin main

echo ""
echo "✅ GitHub setup complete!"
echo "🔗 Repository: https://github.com/KevPtsm/w-diet"
