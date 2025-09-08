#!/bin/bash

# Function to detect JAVA_HOME if not set
detect_java_home() {
    if [ -z "$JAVA_HOME" ]; then
        echo "JAVA_HOME not set. Trying to detect..."
        # Try to find Java installation automatically
        JAVA_PATH=$(readlink -f $(which java) 2>/dev/null | sed "s:/bin/java::")
        if [ -d "$JAVA_PATH" ]; then
            export JAVA_HOME="$JAVA_PATH"
            export PATH=$JAVA_HOME/bin:$PATH
            echo "JAVA_HOME set to $JAVA_HOME"
        else
            echo "Could not detect JAVA_HOME automatically. Please set it manually."
            exit 1
        fi
    else
        echo "JAVA_HOME is already set to $JAVA_HOME"
    fi
}

# Detect or set JAVA_HOME
detect_java_home

# Array of microservice directories
MICROSERVICES=("inventoryservice" "apigateway" "orderservice" "bookingservice")

# Loop through each microservice and run tests
for SERVICE in "${MICROSERVICES[@]}"
do
    if [ -d "$SERVICE" ]; then
        echo "----------------------------------------"
        echo "Running tests for $SERVICE"
        echo "----------------------------------------"
        cd "$SERVICE" || { echo "Cannot enter directory $SERVICE"; exit 1; }

        # Run Maven tests
        if [ -f "pom.xml" ]; then
            ./mvnw clean test || mvn clean test
        # If using Gradle
        elif [ -f "build.gradle" ]; then
            ./gradlew clean test
        else
            echo "No build file found in $SERVICE, skipping..."
        fi

        cd ..
    else
        echo "Directory $SERVICE does not exist, skipping..."
    fi
done

echo "All tests completed."
