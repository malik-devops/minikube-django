FROM python:3.9.10

WORKDIR /app

COPY requirements.txt .

RUN pip3 install --upgrade pip

RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 80

CMD ["python3", "manage.py", "runserver", "0.0.0.0:80"]
