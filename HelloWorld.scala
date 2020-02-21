import org.apache.spark.sql.SparkSession
//spark-submit --class SimpleApp  --master local\[4\] target/scala-2.12/simple-project_2.12-1.0.jar /Users/parmod.kumar/reporting/hello_word_spark/dockerfile
object SimpleApp {
  def main(args: Array[String]) {
    val logFile =  args(0)
    val spark = SparkSession.builder.appName("Simple Application").getOrCreate()
    val logData = spark.read.textFile(logFile).cache()
    val numAs = logData.filter(line => line.contains("sbt")).count()
    val numBs = logData.filter(line => line.contains("RUN")).count()
    print(s"Lines with apt: $numAs, Lines with run: $numBs")
    for ( x <- args ) {
         print( x )
     }
    spark.stop()
  }
  def print(l: String){
    println("-------" + l)
  }
}
