#!/bin/bash

# Ourbit POS Deploy Script
# Script untuk deploy aplikasi Flutter web ke Firebase Hosting

set -e  # Exit on any error

echo "🚀 Starting deployment process..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    print_warning "Firebase CLI is not installed. Installing..."
    npm install -g firebase-tools
fi

# Check if user is logged in to Firebase
if ! firebase projects:list &> /dev/null; then
    print_warning "Not logged in to Firebase. Please login first:"
    echo "firebase login"
    exit 1
fi

print_status "Building Flutter web app..."
flutter build web

if [ $? -eq 0 ]; then
    print_success "Flutter build completed successfully!"
else
    print_error "Flutter build failed!"
    exit 1
fi

print_status "Deploying to Firebase Hosting..."
firebase deploy --only hosting:ourbit-cashier

if [ $? -eq 0 ]; then
    print_success "Deployment completed successfully!"
    echo ""
    echo "🌐 Your app is now live at:"
    echo "   https://ourbit-cashier.web.app"
    echo ""
    echo "📊 Firebase Console:"
    echo "   https://console.firebase.google.com/project/ourbit-9ac6d/overview"
    echo ""
    print_status "Testing deployment..."
    
    # Wait a moment for deployment to propagate
    sleep 5
    
    # Test if the site is accessible (basic check)
    if curl -s -o /dev/null -w "%{http_code}" https://ourbit-cashier.web.app | grep -q "200"; then
        print_success "Site is accessible!"
    else
        print_warning "Site might still be deploying. Please check manually in a few minutes."
    fi
else
    print_error "Deployment failed!"
    exit 1
fi

echo ""
print_success "🎉 Deployment process completed!"
echo ""
echo "📝 Next steps:"
echo "   1. Test the application at https://ourbit-cashier.web.app"
echo "   2. Update your Next.js CMS with the new URL"
echo "   3. Test the token integration"
echo "" 