FROM python:3.10-slim

WORKDIR /app

# System dependencies for OpenCV, InsightFace, ONNX Runtime
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    build-essential \
    cmake \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create config directory for Ultralytics
RUN mkdir -p /root/.config/Ultralytics

COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install onnxruntime (version 1.15.1 works well with Python 3.10)
RUN pip install --no-cache-dir onnxruntime==1.15.1

# Verify onnxruntime works
RUN python -c "import onnxruntime; print('ONNX Runtime version:', onnxruntime.__version__)"

# Install remaining dependencies
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN mkdir -p uploads

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
