# Java Mojito Runner

This project combines the Java implementations from the TechEmpower Benchmark repository ([https://github.com/the-benchmarker/web-frameworks/tree/develop/java](https://github.com/the-benchmarker/web-frameworks/tree/develop/java)) with the Mojitos benchmarking tool ([https://gitlab.irit.fr/sepia-pub/mojitos](https://gitlab.irit.fr/sepia-pub/mojitos)) to provide a **starting baseline for energy profiling of Java web frameworks**.

The goal is to offer a reproducible environment for building, running, and measuring Java web applications under controlled conditions.

---
## ⚙️ Prerequisites
### 1. Docker
You must have Docker installed and running.
* Official website: [https://www.docker.com/get-started](https://www.docker.com/get-started)
Verify installation:
```bash
docker --version
```

### 2. Bash environment
The `run.sh` script was designed for **bash**.
* ✅ Works natively on Linux and macOS
* ⚠️ On Windows, you may adapt
---

## 🚀 How to Run

Basic usage:

```bash
./run.sh <app_name> [num_requests]
```

### Parameters

* `app_name` → folder inside `code/`
* `num_requests` → number of curl requests (optional)

If `num_requests` is not provided, the default is:

```
100
```

---

### ✅ Example

```bash
./run.sh quarkus
```

or

```bash
./run.sh quarkus 500
```

---

## 🐳 What the Script Does

The `run.sh` script:

1. Builds the Docker image for the selected framework
2. Removes any previous container with the same name
3. Starts the container
4. Waits for the service to become available
5. Executes the configured number of HTTP requests
6. Stores benchmark results in `logs/mojitolog.csv`

## 📊 Output Logs

After each execution, a CSV file is generated at:

```
logs/mojitolog.csv
```

This file is mounted from the container and updated in real time.

Each run will overwrite the previous CSV unless you rename or move it.

---
## ⚠️ Notes

* Port **3000** must be free on your host
* The container runs in `--privileged` mode for performance counters
* If networking issues occur, ensure Docker Desktop / daemon is running properly

---

## 🧪 Troubleshooting

If Docker fails to pull or build:

* try `docker system prune -a`
* rebuild the base image `docker build -t vinixnan/javamojito:java25 .`
* check your CPU architecture (`uname -m`)

---