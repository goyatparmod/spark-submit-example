# spark-submit-example
spark-submit example using docker

``` 
  sbt package

  docker run -it --rm -e FILE_PATH=dockerfile hw_sprk:v21
  docker build . -t hw_sprk:v21
