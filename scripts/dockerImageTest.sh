#!/bin/bash
while getopts t:d:v: flag; do
    case "${flag}" in
    t) DATE="${OPTARG}" ;;
    d) DRIVER="${OPTARG}" ;;
    v) OL_LEVEL="${OPTARG}";;
    *) echo "Invalid option" ;;
    esac
done

echo "Testing latest OpenLiberty Docker image"

sed -i "\#<noPassword>true</noPassword>#a<install><runtimeUrl>https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/nightly/$DATE/$DRIVER</runtimeUrl></install>" system/pom.xml module-getting-started/pom.xml module-openapi/pom.xml module-config/pom.xml
cat system/pom.xml
sed -i "\#<artifactId>liberty-maven-plugin</artifactId>#a<configuration><install><runtimeUrl>https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/nightly/$DATE/$DRIVER</runtimeUrl></install></configuration>" module-getting-started/pom.xml module-openapi/pom.xml module-config/pom.xml
cat module-getting-started/pom.xml
cat module-openapi/pom.xml
cat module-config/pom.xml

sed -i "\#<configuration>#a<install><runtimeUrl>https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/nightly/$DATE/$DRIVER</runtimeUrl></install>" module-persisting-data/pom.xml module-securing/pom.xml module-jwt/pom.xml module-testcontainers/pom.xml
cat module-persisting-data/pom.xml
cat module-securing/pom.xml
cat module-jwt/pom.xml
cat module-testcontainers/pom.xml

if [[ "$OL_LEVEL" != "" ]]; then
  sed -i "s;FROM icr.io/appcafe/open-liberty:full-java17-openj9-ubi;FROM cp.stg.icr.io/cp/olc/open-liberty-vnext:$OL_LEVEL-full-java17-openj9-ubi;g" module-kubernetes/Dockerfile
else
  sed -i "s;FROM icr.io/appcafe/open-liberty:full-java17-openj9-ubi;FROM cp.stg.icr.io/cp/olc/open-liberty-daily:full-java17-openj9-ubi;g" module-kubernetes/Dockerfile
fi
cat module-kubernetes/Dockerfile

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin cp.stg.icr.io
if [[ "$OL_LEVEL" != "" ]]; then
  docker pull -q "cp.stg.icr.io/cp/olc/open-liberty-vnext:$OL_LEVEL-full-java17-openj9-ubi"
  echo "build level:"; docker inspect --format "{{ index .Config.Labels \"org.opencontainers.image.revision\"}}" "cp.stg.icr.io/cp/olc/open-liberty-vnext:$OL_LEVEL-full-java17-openj9-ubi"
else
  docker pull -q "cp.stg.icr.io/cp/olc/open-liberty-daily:full-java17-openj9-ubi"
  echo "build level:"; docker inspect --format "{{ index .Config.Labels \"org.opencontainers.image.revision\"}}" "cp.stg.icr.io/cp/olc/open-liberty-daily:full-java17-openj9-ubi"
fi

../scripts/testApp.sh
