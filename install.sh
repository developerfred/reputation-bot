#!/bin/bash
set -e

echo "🔧 Installing GitHub Reputation Bot..."

# Check Python version
PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f1,2)
REQUIRED_PYTHON="3.11"

if [[ $(echo -e "$PYTHON_VERSION\n$REQUIRED_PYTHON" | sort -V | head -n1) != "$REQUIRED_PYTHON" ]]; then
    echo "⚠️  Python 3.11+ recommended. Found: $PYTHON_VERSION"
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate venv
echo "⚡ Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📥 Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Copy .env.example to .env if .env doesn't exist
if [ ! -f ".env" ]; then
    echo "📝 Creating .env from template..."
    cp .env.example .env
    echo "⚠️  Please edit .env with your configuration!"
else
    echo "✅ .env already exists"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Edit .env with your configuration"
echo "  2. Run: source venv/bin/activate"
echo "  3. Run: python app.py"
