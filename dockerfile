#d run -it --rm -e FILE_PATH=dockerfile hw_sprk:v21
FROM alpine:3.10 AS base

ARG SPARK_VERSION=3.0.0-preview2
ARG HADOOP_VERSION_SHORT=3.2
ARG HADOOP_VERSION=3.2.0
ARG AWS_SDK_VERSION=1.11.375
ARG PATH=target/scala-2.12/simple-project_2.12-1.0.jar
ENV FILE_PATH=/target/scala-2.12

RUN apk add --no-cache bash openjdk8-jre python3

# Download and extract Spark
RUN wget -qO- https://www-eu.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION_SHORT}.tgz | tar zx -C /opt && \
    mv /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION_SHORT} /opt/spark

# Configure Spark to respect IAM role given to container
RUN echo spark.hadoop.fs.s3a.aws.credentials.provider=com.amazonaws.auth.EC2ContainerCredentialsProviderWrapper > /opt/spark/conf/spark-defaults.conf

# Add hadoop-aws and aws-sdk
RUN wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar -P /opt/spark/jars/ && \
    wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_SDK_VERSION}/aws-java-sdk-bundle-${AWS_SDK_VERSION}.jar -P /opt/spark/jars/

ENV PATH="/opt/spark/bin:${PATH}"
ENV PYSPARK_PYTHON=python3

FROM base AS build
WORKDIR /HelloWorld
ADD .  /HelloWorld

# Setting proper hostname before running spark, see https://stackoverflow.com/a/55652399/7098262
CMD ["/bin/echo", "Hello world"]
ENTRYPOINT ["/bin/sh", "-c", "echo ${FILE_PATH}; echo 127.0.0.1 $HOSTNAME >> /etc/hosts; spark-submit --class SimpleApp --master local[4] target/scala-2.12/simple-project_2.12-1.0.jar $FILE_PATH"]

