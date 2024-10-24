## Get to know a handful of built-in functions in Terraform

#### Setup

> Make sure you are in the correct folder

```bash
cd ~/clouddrive/tfw/contoso
```

#### Launch Interactive Console

Terraform comes with an interactive console that is very handy to evaluate expresssions and exploring functions 

```bash
terraform console
```
You should see your prompt now appearing as below. 

```bash
>_
```

To exit the console at any time and go back to cloud shell's terminal, just type `exit` or press `ctrl + c`. To clear the screen, press `ctrl + l`

#### Explore and practice a handful of built-in functions using the console

> Built-in functions greatly help with writing cleaner code. We will use some of the functions in our config later as well.

* Numeric Functions

```bash
# max value
max(5,12,9)

# max value from a list
max([12,54,3]...)

# ceil to return closest whole number that is greater than or equal to given value
ceil(5.3)

# parseint - parse a string as int for given base (decimal here)
parseint("35", 10)
```

* String Functions

```bash
# split string into a list
split(",", "foo,bar,baz")

# convert list to a string based on a separator
join(" ", ["foo", "bar", "baz"])

# convert string to lower-case
lower("HELLO")

```

* Collection Functions

```bash
# retrieve keys from a map as a list
keys({a=1, c=2, d=3})

# sort a list
sort(["e", "d", "a"])

# get length of string, list or map
length([1, 2, 3, 4, 5])
```

* Type Conversion functions

```bash
# convert list to a set to remove duplicates 
toset(["c", "b", "b"])
```

* Encoding Functions

```bash
# decode a base64 encoded string
base64decode("SGVsbG8gV29ybGQ=")

# encode given value as a json string
jsonencode({"hello"="world"})

```

* Hash and Crypto Functions

```bash
# compute sha256 for given string
sha256("hello world")

```

* Filesystem functions

```bash
# get absolute path of given filesystem path
abspath(path.root)

# read file contents and return them as a string
file("main.tf")

```

* Date and time functions

```bash
# timeadd(timestamp, duration)
timeadd("2020-06-08T00:00:00Z", "10m")
```

* IP Network functions

```bash
# calculate a subnet address within given IP network address prefix.
# cidrsubnet(prefix, newbits, netnum)
cidrsubnet("172.16.0.0/16", 8, 0)
```


> For a full list of built-in functions, see below and try out the ones that you find interesting.
https://www.terraform.io/docs/configuration/functions.html



