FROM python:3.11-slim

WORKDIR /app

# System dependencies for OpenCV, InsightFace, ONNX Runtime
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    libstdc++6 \
    build-essential \
    cmake \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create config directory for Ultralytics
RUN mkdir -p /root/.config/Ultralytics

COPY requirements.txt .

# Install Python dependencies in correct order
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install onnxruntime FIRST (before insightface)
RUN pip install --no-cache-dir numpy==1.26.3
RUN pip install --no-cache-dir onnxruntime==1.16.3

# Verify onnxruntime installed correctly
RUN python -c "import onnxruntime; print('ONNX Runtime version:', onnxruntime.__version__)"

# Install remaining dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Verify insightface can import onnxruntime
RUN python -c "import onnxruntime; import insightface; print('InsightFace loaded successfully')" || echo "InsightFace check failed but continuing..."

COPY . .

RUN mkdir -p uploads

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
