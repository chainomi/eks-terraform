FROM python:3.8-alpine

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh

# Make dir app
RUN mkdir /app_flask

WORKDIR /app_flask

# Copy the source from the current directory to the Working Directory inside the container
COPY . .

#install modules
RUN pip install -r requirements.txt


EXPOSE 8000


# Run the executable
CMD ["python", "app_flask_api.py"]