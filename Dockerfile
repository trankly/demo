FROM python:3.6-alpine3.8

RUN mkdir /app
WORKDIR /app
ADD ./ /app/
RUN pip install pipenv \
    && pipenv install --system --deploy --ignore-pipfile
CMD ["python", "/app/server.py"]