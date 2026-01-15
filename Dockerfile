FROM python:3.11-bookworm

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
    execstack \
    && rm -rf /var/lib/apt/lists/*

# Create config directory for Ultralytics
RUN mkdir -p /root/.config/Ultralytics

COPY requirements.txt .

# Install Python dependencies in correct order
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install numpy first
RUN pip install --no-cache-dir numpy==1.26.3

# Install onnxruntime (newer version that fixes execstack issue)
RUN pip install --no-cache-dir onnxruntime==1.17.0

# Fix execstack issue for onnxruntime
RUN execstack -c /usr/local/lib/python3.11/site-packages/onnxruntime/capi/*.so || true

# Verify onnxruntime installed correctly
RUN python -c "import onnxruntime; print('ONNX Runtime version:', onnxruntime.__version__)"

# Install remaining dependencies
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN mkdir -p uploads

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
