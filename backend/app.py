from flask import Flask, render_template, request, redirect
from werkzeug.utils import secure_filename
from PIL import Image
import tempfile
import io
import os
import boto3

app = Flask(__name__)

RAW_BUCKET = "highshow-image-platform-377846699531-raw-images"

PROCESSED_BUCKET = "highshow-image-platform-377846699531-processed-images"

s3 = boto3.client("s3")


@app.route("/")
def index():

    images = []

    try:
        response = s3.list_objects_v2(Bucket=RAW_BUCKET)

        if "Contents" in response:
            images = [obj["Key"] for obj in response["Contents"]]

    except Exception as e:
        print(f"S3 Error: {e}")

    return render_template(
        "index.html",
        images=images
    )


@app.route("/upload", methods=["POST"])
def upload():

    try:

        file = request.files["image"]

        if not file or file.filename == "":
            return redirect("/")

        filename = secure_filename(file.filename)

        #
        # Read file once
        #
        file_content = file.read()

        #
        # Upload original image
        #
        s3.put_object(
            Bucket=RAW_BUCKET,
            Key=filename,
            Body=file_content
        )

        #
        # Open image from memory
        #
        image = Image.open(io.BytesIO(file_content))

        #
        # Convert PNG RGBA to RGB if needed
        #
        if image.mode == "RGBA":
            image = image.convert("RGB")

        image.thumbnail((800, 800))

        processed_name = f"processed-{filename}"

        with tempfile.NamedTemporaryFile(
            suffix=".jpg",
            delete=False
        ) as temp:

            image.save(
                temp.name,
                "JPEG"
            )

            s3.upload_file(
                temp.name,
                PROCESSED_BUCKET,
                processed_name
            )

        os.remove(temp.name)

        print(f"Successfully processed {filename}")

    except Exception as e:

        print(f"ERROR: {e}")

    return redirect("/")


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5002,
        debug=True
    )