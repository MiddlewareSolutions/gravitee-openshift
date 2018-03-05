# create pv
# persistentvolumes\create_pv.cmd

# create project
oc login -u developer -p developer
oc new-project gravitee

# add service account for host path
oc create serviceaccount gravitee -n gravitee

# affect policy
oc login -u system:admin
oc project gravitee
oc adm policy add-scc-to-user anyuid -z gravitee

oc login -u developer -p developer

set GRAVITEEIO_VERSION=1.14.1

# 1. definie build
# 2. start building
# 3. tag this version

# gateway
oc new-build ../ --name=gateway --context-dir=images/gateway/ --strategy=docker --build-arg=GRAVITEEIO_VERSION=%GRAVITEEIO_VERSION%
oc start-build gateway --build-arg=GRAVITEEIO_VERSION=%GRAVITEEIO_VERSION% --wait=true
oc tag gateway:latest gateway:%GRAVITEEIO_VERSION%

# management-api
oc new-build ../ --name=management-api --context-dir=images/management-api/ --strategy=docker --build-arg=GRAVITEEIO_VERSION=%GRAVITEEIO_VERSION%
oc start-build management-api --build-arg=GRAVITEEIO_VERSION=%GRAVITEEIO_VERSION% --wait=true
oc tag management-api:latest management-api:%GRAVITEEIO_VERSION%

# management-ui
oc new-build ../ --name=management-ui --context-dir=images/management-ui/ --strategy=docker --build-arg=GRAVITEEIO_VERSION=%GRAVITEEIO_VERSION%
oc start-build management-ui --build-arg=GRAVITEEIO_VERSION=%GRAVITEEIO_VERSION% --wait=true
oc tag management-ui:latest management-ui:%GRAVITEEIO_VERSION%

oc create -f persistentvolumes/elasticdata.yaml
oc create -f persistentvolumes/mongodata.yaml

# import OpenShift Template
oc process -f .\template-graviteeapim.yaml -p GRAVITEE_VERSION=%GRAVITEEIO_VERSION%  | oc create -f -

set GRAVITEEAM_VERSION=1.6.2

# am-gateway
oc new-build ../ --name=am-gateway --context-dir=images/am-gateway/ --strategy=docker --build-arg=GRAVITEEAM_VERSION=%GRAVITEEIO_VERSION%
oc start-build am-gateway --build-arg=GRAVITEEAM_VERSION=%GRAVITEEAM_VERSION% --wait=true
oc tag am-gateway:latest am-gateway:%GRAVITEEAM_VERSION%

# am-webui
oc new-build ../ --name=am-webui --context-dir=images/am-webui/ --strategy=docker --build-arg=GRAVITEEAM_VERSION=%GRAVITEEAM_VERSION%
oc start-build am-webui --build-arg=GRAVITEEAM_VERSION=%GRAVITEEAM_VERSION% --wait=true
oc tag am-webui:latest am-webui:%GRAVITEEAM_VERSION%
