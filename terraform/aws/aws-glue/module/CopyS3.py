import sys

from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from awsglueml.transforms import EntityDetector
from pyspark.context import SparkContext

args = getResolvedOptions(sys.argv, ["JOB_NAME", "DATA_BUCKET"])
data_bucket = args["DATA_BUCKET"]
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Script generated for node Input
Input_node1705505530241 = glueContext.create_dynamic_frame.from_options(
    format_options={"multiline": True},
    connection_type="s3",
    format="json",
    connection_options={
        "paths": [f"s3://{data_bucket}/data/input/"],
        "recurse": True,
    },
    transformation_ctx="Input_node1705505530241",
)

# Script generated for node Detect Sensitive Data
detection_parameters = {
    "CREDIT_CARD": [{"action": "REDACT", "actionOptions": {"redactText": "******"}}]
}

entity_detector = EntityDetector()
DetectSensitiveData_node1705506030398 = entity_detector.detect(
    Input_node1705505530241, detection_parameters, "DetectedEntities", "HIGH"
)

# Script generated for node Amazon S3
AmazonS3_node1705506389906 = glueContext.write_dynamic_frame.from_options(
    frame=DetectSensitiveData_node1705506030398,
    connection_type="s3",
    format="json",
    connection_options={
        "path": f"s3://{data_bucket}/data/output/",
        "partitionKeys": [],
    },
    transformation_ctx="AmazonS3_node1705506389906",
)

job.commit()
