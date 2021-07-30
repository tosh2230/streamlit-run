FROM python:3.9.5

RUN pip install --upgrade pip
COPY requirements.txt .
RUN pip install --no-cache-dir -r  requirements.txt 

WORKDIR /app
COPY app.py . 
CMD streamlit run app.py --server.port=${PORT} --browser.serverAddress="0.0.0.0"
