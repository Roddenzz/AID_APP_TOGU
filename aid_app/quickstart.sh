#!/bin/bash
# Quick Start Script for TOGU Aid App

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== TOGU Aid App - Quick Start ===${NC}\n"

# Check Flutter installation
echo -e "${YELLOW}[1/5] Checking Flutter installation...${NC}"
if command -v flutter &> /dev/null; then
    echo -e "${GREEN}✓ Flutter found${NC}"
    flutter --version
else
    echo -e "${RED}✗ Flutter not found${NC}"
    echo "Please install Flutter from https://flutter.dev"
    exit 1
fi

echo ""

# Clone/Navigate to project
echo -e "${YELLOW}[2/5] Setting up project directory...${NC}"
if [ ! -d "aid_app" ]; then
    echo "aid_app directory not found. Please navigate to the project directory first."
    exit 1
fi
cd aid_app || exit

echo -e "${GREEN}✓ Project directory ready${NC}\n"

# Clean and get dependencies
echo -e "${YELLOW}[3/5] Installing dependencies...${NC}"
flutter clean
flutter pub get
echo -e "${GREEN}✓ Dependencies installed${NC}\n"

# Check for devices
echo -e "${YELLOW}[4/5] Checking for connected devices...${NC}"
flutter devices
echo ""

# Display next steps
echo -e "${YELLOW}[5/5] Setup complete!${NC}\n"

echo -e "${GREEN}Next steps:${NC}"
echo ""
echo -e "${YELLOW}To run on device:${NC}"
echo "  flutter run"
echo ""
echo -e "${YELLOW}To build Android release:${NC}"
echo "  flutter build apk --release"
echo ""
echo -e "${YELLOW}To build Windows release:${NC}"
echo "  flutter build windows --release"
echo ""
echo -e "${YELLOW}To run tests:${NC}"
echo "  flutter test"
echo ""
echo -e "${YELLOW}To analyze code:${NC}"
echo "  flutter analyze"
echo ""
echo -e "${GREEN}Important: Don't forget to configure staff users in:${NC}"
echo "  lib/services/database_service.dart"
echo ""
echo -e "${GREEN}For more information, see:${NC}"
echo "  - README.md - Project overview"
echo "  - INSTALL.md - Installation guide"
echo "  - BUILD.md - Build instructions"
echo "  - PROJECT_SUMMARY.md - What's been created"
echo ""
