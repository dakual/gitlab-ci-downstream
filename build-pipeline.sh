#!/bin/sh

cat <<EOF
include: '/ci-templates/helm-ci.yml'

stages:
  - test
  - dry-run
  - push
  - install
  - uninstall

EOF

for f in $(find charts/* -maxdepth 0 -type d)
do
  CHART_VERSION=$(grep "^version:" ${f}/Chart.yaml | cut -d' ' -f2-)
  CHART_RELEASE="${f##*/}-${CHART_VERSION}"
  cat <<EOF
${f##*/}:lint:
  stage: test
  extends: .lint
  variables:
    CHART: "${f##*/}"
  rules:
    - if: '\$CI_COMMIT_TAG =~ "/^$/"'
      changes:
        - ${f}/**/*

${f##*/}:dry-run:
  stage: dry-run
  extends: .dry-run
  variables:
    CHART: "${f##*/}"
  rules:
    - if: '\$CI_COMMIT_TAG =~ "/^$/"'
      changes:
        - ${f}/**/*

${f##*/}:push:
  stage: push
  extends: .push
  variables:
    CHART: "${f##*/}"
  rules:
    - if: '\$CI_COMMIT_TAG =~ "/^$/"'
      changes:
        - ${f}/**/*

${f##*/}:install:
  stage: install
  extends: .install
  variables:
    CHART: "${f##*/}"
  rules:
    - if: '\$CI_COMMIT_TAG =~ "/^$/"'
      changes:
        - ${f}/Chart.yaml

${f##*/}:uninstall:
  stage: uninstall
  extends: .uninstall
  variables:
    CHART: "${f##*/}"
    
EOF

done
