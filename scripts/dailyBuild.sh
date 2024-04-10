#!/bin/bash
while getopts t:d:b:u:j: flag; do
    case "${flag}" in
    t) DATE="${OPTARG}" ;;
    d) DRIVER="${OPTARG}" ;;
    b) BUILD="${OPTARG}";;
    u) DOCKER_USERNAME="${OPTARG}";;
    j) JDK_LEVEL="${OPTARG}" ;;
    *) echo "Invalid option" ;;
    esac
done

echo "Testing daily build image"

if [ "$JDK_LEVEL" == "11" ]; then
    echo "Test skipped because the guide does not support Java 11."
    exit 0
fi

sed -i "\#<artifactId>liberty-maven-plugin</artifactId>#a<configuration><install><runtimeUrl>https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/nightly/$DATE/$DRIVER</runtimeUrl></install></configuration>" system/pom.xml module-getting-started/pom.xml module-openapi/pom.xml module-config/pom.xml
cat system/pom.xml
cat module-getting-started/pom.xml
cat module-openapi/pom.xml
cat module-config/pom.xml

sed -i "\#<configuration>#a<install><runtimeUrl>https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/nightly/$DATE/$DRIVER</runtimeUrl></install>" module-persisting-data/pom.xml module-securing/pom.xml module-jwt/pom.xml module-testcontainers/pom.xml
cat module-persisting-data/pom.xml
cat module-securing/pom.xml
cat module-jwt/pom.xml
cat module-testcontainers/pom.xml

sed -i "s;FROM icr.io/appcafe/open-liberty:full-java17-openj9-ubi;FROM $DOCKER_USERNAME/olguides:$BUILD-java17;g" module-kubernetes/Dockerfile
cat module-kubernetes/Dockerfile

sudo -E ../scripts/testApp.sh
