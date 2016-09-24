//
// MIT License
// Copyright (c) 2016 iAchieved.it
//
import Glibc
import MySQL
import Foundation
import Jay


print("Hello, world!")

print("Let's add some records to a database")

var mysql:Database
do {
  mysql = try Database(host:"localhost",
                    user:"swift",
                    password:"swiftpass",
                    database:"swift_test")
  try mysql.execute("SELECT @@version")
} catch {
  print("Unable to connect to MySQL:  \(error)")
  exit(-1)
}
let timeString = String(format: "The current time is %02d:%02d", 10, 4)

print("Let's create a new table called foo and populate it")

do {
  try mysql.execute("DROP TABLE IF EXISTS foo")
  try mysql.execute("CREATE TABLE foo (bar INT(4), baz VARCHAR(16))")

  for i in 1...10 {
    let int    = randomInt()
    let string = randomString(ofLength:16)
    try mysql.execute("INSERT INTO foo VALUES (\(int), '\(string)')")
  }

  print("Rows populated, now query")

  // Query
  let results = try mysql.execute("SELECT * FROM foo")
  for result in results {
    if let bar = result["bar"]?.int,
       let baz = result["baz"]?.string {
      print("\(bar)\t\(baz)")
    }
  }
} catch {
  print("Error:  \(error)")
  exit(-1)
}

do {
  // DATE example
  // TEXT example
  // POINT example
  // JSON example

  print("Let's create a table called samples and populate a record")

  try mysql.execute("DROP TABLE IF EXISTS samples")
  try mysql.execute("CREATE TABLE samples (id INT PRIMARY KEY AUTO_INCREMENT, created_at DATETIME, location POINT, sample JSON, comment TEXT)")

  let now              = Date()
  let formatter        = DateFormatter()
  formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
  let created_at       = formatter.string(from:now)

  let point = (37.20262, -112.98785)

  let sample:[String:Any] = [
    "heading":90,
    "gps":[
      "latitude":37.20262,
      "longitude":-112.98785
    ],
    "speed":82,
    "temperature":200
  ]
  let data = try Jay(formatting:.minified).dataFromJson(any:sample) // [UInt8]
  if let sampleJSON = String(data:Data(data), encoding:.utf8) {
    let stmt = "INSERT INTO samples (created_at, location, sample) VALUES ('\(created_at)', POINT\(point), '\(sampleJSON)')"
    print("Inserting a sample with:  \(stmt)")
    try mysql.execute(stmt)
  }

  print("Querying based upon JSON (speed > 80)")
  let results = try mysql.execute("SELECT created_at,sample FROM samples where JSON_EXTRACT(sample, '$.speed') > 80")

  print("Results:  \(results.count)")
  for result in results {
    if let sample = result["sample"]?.object,
       let speed      = sample["speed"]?.int,
       let temperature = sample["temperature"]?.int,
       let created_at  = result["created_at"]?.string {
      print("Time:\(created_at)\tSpeed:\(speed)\tTemperature:\(temperature)")
    }
  }
  
}


print("And we're done")
