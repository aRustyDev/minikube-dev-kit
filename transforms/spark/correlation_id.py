from pyspark import SparkContext
from operator import add

# Cinnamon Neopipo
# Pipipi (pi)^3 (Brown Creeper)
# Jetstream
spark = SparkSession.builder.appName('Jetstream PoC').config('spark.memory.offHeap.enabled','true').config('spark.memory.offHeap.size','10g').getOrCreate()
df = spark.read.csv('datacamp_ecommerce.csv',header=True,escape="\"")

data = sc.parallelize(list('Hello World'))
counts = data.map(lambda x:
	(x, 1)).reduceByKey(add).sortBy(lambda x: x[1],
	 ascending=False).collect()

for (word, count) in counts:
    print('{}: {}'.format(word, count))
