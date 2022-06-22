
import os
import sys
import datetime

from flask import Flask, request
import requests
import json


from kubernetes import client, config, dynamic
from kubernetes.client import configuration
from kubernetes.client import api_client, ApiException



app = Flask(__name__)


if (os.getenv("KUBERNETES_SERVICE_HOST") is not None):
    config.load_incluster_config()
    
else:
    config.load_kube_config()




@app.route("/")
def home():
    return "flask app for kubernetes v1"

@app.route("/v1/api", methods=['GET'])
def kubeApi_list():

    print("Supported APIs (* is preferred version):")
    print("%-40s %s" %
          ("core", ",".join(client.CoreApi().get_api_versions().versions)))
    for api in client.ApisApi().get_api_versions().groups:
        versions = []
        for v in api.versions:
            name = ""
            if v.version == api.preferred_version.version and len(
                    api.versions) > 1:
                name += "*"
            name += v.version
            versions.append(name)
        print("%-40s %s" % (api.name, ",".join(versions)))
        return "%-40s %s" % (api.name, ",".join(versions))


@app.route("/pods", methods=['GET'])
def main():

    print("Active host is %s" % configuration.Configuration().host)

    v1 = client.CoreV1Api()
    print("Listing pods with their IPs:")
    ret = v1.list_pod_for_all_namespaces(watch=False)
    for item in ret.items:
        print("%s\t%s\t%s" % (item.status.pod_ip, item.metadata.namespace, item.metadata.name))
    return "pods listed in console"


@app.route("/create_map", methods=['POST'])
def config_map_create():
    # Creating a dynamic client

    if (os.getenv("KUBERNETES_SERVICE_HOST") is not None):
        client = dynamic.DynamicClient(
            api_client.ApiClient(configuration=config.load_incluster_config())
        )    
    else:
        client = dynamic.DynamicClient(
            api_client.ApiClient(configuration=config.load_kube_config())
        )        

    # fetching the configmap api
    api = client.resources.get(api_version="v1", kind="ConfigMap")

    request_data = request.get_json()
    
    configmap_name = request_data['configmap_name']
    redis_host = request_data['redis_host']
    redis_port = request_data['redis_port']
    configmap_manifest = {
                "apiVersion": "v1",
                "kind": "ConfigMap",
                "metadata": {
                    "name": configmap_name
                },
                "data": {
                    "REDIS_HOST": redis_host,
                    "REDIS_PORT": redis_port
                }
            }
    
    try:
        configmap_list = api.get(namespace="default",name=configmap_name)
        print(configmap_list)

    except Exception as e:
        print("WARNING: ConfigMap " + configmap_name + " not found in namespace. We will create it.")
        configmap = api.create(body=configmap_manifest, namespace="default")
        print(configmap)
        return f"\n[INFO] configmap {configmap_name} created\n"

@app.route("/update_map", methods=['POST'])
def config_map_update():
    # Creating a dynamic client

    if (os.getenv("KUBERNETES_SERVICE_HOST") is not None):
        client = dynamic.DynamicClient(
            api_client.ApiClient(configuration=config.load_incluster_config())
        )    
    else:
        client = dynamic.DynamicClient(
            api_client.ApiClient(configuration=config.load_kube_config())
        )      

    # fetching the configmap api
    api = client.resources.get(api_version="v1", kind="ConfigMap")

    request_data = request.get_json()
    
    configmap_name = request_data['configmap_name']
    redis_host = request_data['redis_host']
    redis_port = request_data['redis_port']
    configmap_manifest = {
                "apiVersion": "v1",
                "kind": "ConfigMap",
                "metadata": {
                    "name": configmap_name
                },
                "data": {
                    "REDIS_HOST": redis_host,
                    "REDIS_PORT": redis_port
                }
            }
    
    try:
        configmap_patched = api.patch(
        name=configmap_name, namespace="default", body=configmap_manifest
    )
        print(configmap_patched)
        print("\n[INFO] configmap `test-configmap` updated\n")
        print("NAME:\n%s\n" % (configmap_patched.metadata.name))
        print("DATA:\n%s\n" % (configmap_patched.data))
        return f"\n[INFO] configmap {configmap_name} updated\n"

    except ApiException as e:
        print("Exception when calling CoreV1Api->patch_namespaced_config_map: %s\n" % e)
        return "Exception when calling CoreV1Api->patch_namespaced_config_map: %s\n" % e


@app.route("/delete_map", methods=['POST'])
def config_map_delete():

    # Creating a dynamic client

    if (os.getenv("KUBERNETES_SERVICE_HOST") is not None):
        client = dynamic.DynamicClient(
            api_client.ApiClient(configuration=config.load_incluster_config())
        )    
    else:
        client = dynamic.DynamicClient(
            api_client.ApiClient(configuration=config.load_kube_config())
        )    


    # fetching the configmap api
    api = client.resources.get(api_version="v1", kind="ConfigMap")

    request_data = request.get_json()
    
    configmap_name = request_data['configmap_name']

    try:
        configmap_deleted = api.delete(name=configmap_name, body={}, namespace="default")
        
        print(configmap_deleted)
        print("\n[INFO] configmap {configmap_name} deleted\n")
        return f"\n[INFO] configmap {configmap_name} deleted\n"

    except ApiException as e:
        print("Exception when deleting config map {configmap_name}: %s\n" % e)
        return "Exception when deleting config map {configmap_name}: %s\n" % e

@app.route("/update_map_restart_deployment", methods=['POST'])
def update_map_restart_deployment():
        
    request_data = request.get_json()

    deployment = request_data['deployment_name']
    configmap_name = request_data['configmap_name']
    namespace = "default"
    
    
    def config_map_update1():
        # Creating a dynamic client

        if (os.getenv("KUBERNETES_SERVICE_HOST") is not None):
            client = dynamic.DynamicClient(
                api_client.ApiClient(configuration=config.load_incluster_config())
            )    
        else:
            client = dynamic.DynamicClient(
                api_client.ApiClient(configuration=config.load_kube_config())
            ) 
            
        # fetching the configmap api
        api = client.resources.get(api_version="v1", kind="ConfigMap")


        redis_host = request_data['redis_host']
        redis_port = request_data['redis_port']
        configmap_manifest = {
                    "apiVersion": "v1",
                    "kind": "ConfigMap",
                    "metadata": {
                        "name": configmap_name
                    },
                    "data": {
                        "REDIS_HOST": redis_host,
                        "REDIS_PORT": redis_port
                    }
                }

        try:
            configmap_patched = api.patch(
            name=configmap_name, namespace="default", body=configmap_manifest
        )
            print(configmap_patched)
            print("\n[INFO] configmap `test-configmap` updated\n")
            print("NAME:\n%s\n" % (configmap_patched.metadata.name))
            print("DATA:\n%s\n" % (configmap_patched.data))
            return f"\n[INFO] configmap {configmap_name} updated\n"

        except ApiException as e:
            print("Exception when calling CoreV1Api->patch_namespaced_config_map: %s\n" % e)
            return "Exception when calling CoreV1Api->patch_namespaced_config_map: %s\n" % e
    config_map_update1()
    
    def deployment_restart1():

        #config.load_incluster_config()
        
        # Enter name of deployment and "namespace"

        v1_apps = client.AppsV1Api()

        now = datetime.datetime.utcnow()
        now = str(now.isoformat("T") + "Z")
        body = {
            'spec': {
                'template':{
                    'metadata': {
                        'annotations': {
                            'kubectl.kubernetes.io/restartedAt': now
                        }
                    }
                }
            }
        }
        try:
            deployment_restarted = v1_apps.patch_namespaced_deployment(deployment, namespace, body, pretty='true')
            print(deployment_restarted)
            return f"\n[INFO] deployment {deployment} restarted\n"


        except ApiException as e:
            print("Exception when calling AppsV1Api->read_namespaced_deployment_status: %s\n" % e)

    deployment_restart1()
    
    
    return f"\n[INFO] configmap {configmap_name} updated and deployment {deployment} restarted \n"

@app.route("/create_deployment", methods=['POST'])
def create_deployment():

    # Creating a dynamic client
    if (os.getenv("KUBERNETES_SERVICE_HOST") is not None):
        client = dynamic.DynamicClient(
            api_client.ApiClient(configuration=config.load_incluster_config())
        )    
    else:
        client = dynamic.DynamicClient(
            api_client.ApiClient(configuration=config.load_kube_config())
        ) 


    # fetching the deployment api
    api = client.resources.get(api_version="apps/v1", kind="Deployment")
    
    request_data = request.get_json()

    deployment_name = request_data['deployment_name']
    command = request_data['command']
    argument = request_data['args']

    deployment_manifest = {
            "apiVersion": "apps/v1",
            "kind": "Deployment",
            "metadata": {
                "name": deployment_name,
                "labels": {
                "app": "java"
                }
            },
            "spec": {
                "replicas": 1,
                "selector": {
                "matchLabels": {
                    "app": "java"
                }
                },
                "template": {
                "metadata": {
                    "labels": {
                    "app": "java"
                    }
                },
                "spec": {
                    "containers": [
                    {
                        "name": "java11",
                        "image": "openjdk:11",
                        "command": [command],
                        "args": [argument]
                    }
                 ]
                }
            }
         }
    }

    deployment = api.create(body=deployment_manifest, namespace="default")

    print(deployment)
    print(f"\n[INFO] deployment {deployment_name} created\n")
    return f"\n[INFO] deployment {deployment_name} created\n"


@app.route("/update_deployment", methods=['POST'])
def update_deployment():
    
    # Creating a dynamic client
    if (os.getenv("KUBERNETES_SERVICE_HOST") is not None):
        client = dynamic.DynamicClient(
            api_client.ApiClient(configuration=config.load_incluster_config())
        )    
    else:
        client = dynamic.DynamicClient(
            api_client.ApiClient(configuration=config.load_kube_config())
        ) 

    # fetching the deployment api
    api = client.resources.get(api_version="apps/v1", kind="Deployment")
    
    request_data = request.get_json()

    deployment_name = request_data['deployment_name']
    command = request_data['command']
    argument = request_data['args']

    deployment_manifest = {
            "apiVersion": "apps/v1",
            "kind": "Deployment",
            "metadata": {
                "name": deployment_name,
                "labels": {
                "app": "java"
                }
            },
            "spec": {
                "replicas": 1,
                "selector": {
                "matchLabels": {
                    "app": "java"
                }
                },
                "template": {
                "metadata": {
                    "labels": {
                    "app": "java"
                    }
                },
                "spec": {
                    "containers": [
                    {
                        "name": "java11",
                        "image": "openjdk:11",
                        "command": [command],
                        "args": [argument]
                    }
                 ]
                }
            }
         }
    }

    deployment_patched = api.patch(
    body=deployment_manifest, name=deployment_name, namespace="default"
    )

    print(deployment_patched)
    print(f"\n[INFO] deployment {deployment_name} updated\n")
    return f"\n[INFO] deployment {deployment_name} updated\n"



@app.route("/delete_deployment", methods=['POST'])
def delete_deployment():
    
    # Creating a dynamic client
    if (os.getenv("KUBERNETES_SERVICE_HOST") is not None):
        client = dynamic.DynamicClient(
            api_client.ApiClient(configuration=config.load_incluster_config())
        )    
    else:
        client = dynamic.DynamicClient(
            api_client.ApiClient(configuration=config.load_kube_config())
        ) 

    # fetching the deployment api
    api = client.resources.get(api_version="apps/v1", kind="Deployment")

    request_data = request.get_json()

    deployment_name = request_data['deployment_name']
    
    deployment_deleted = api.delete(name=deployment_name, body={}, namespace="default")

    print(f"\n[INFO] deployment {deployment_name} deleted\n")
    return f"\n[INFO] deployment {deployment_name} deleted\n"

@app.route("/update_and_restart_deployment", methods=['POST'])
def update_and_restart_deployment():
        
    request_data = request.get_json()

    deployment_name = request_data['deployment_name']
    command = request_data['command']
    argument = request_data['args']
    namespace = "default"

    def update_deployment1():
    
        # Creating a dynamic client
        if (os.getenv("KUBERNETES_SERVICE_HOST") is not None):
            client = dynamic.DynamicClient(
                api_client.ApiClient(configuration=config.load_incluster_config())
            )    
        else:
            client = dynamic.DynamicClient(
                api_client.ApiClient(configuration=config.load_kube_config())
            ) 
            
        # fetching the deployment api
        api = client.resources.get(api_version="apps/v1", kind="Deployment")
        
        deployment_manifest = {
                "apiVersion": "apps/v1",
                "kind": "Deployment",
                "metadata": {
                    "name": deployment_name,
                    "labels": {
                    "app": "java"
                    }
                },
                "spec": {
                    "replicas": 1,
                    "selector": {
                    "matchLabels": {
                        "app": "java"
                    }
                    },
                    "template": {
                    "metadata": {
                        "labels": {
                        "app": "java"
                        }
                    },
                    "spec": {
                        "containers": [
                        {
                            "name": "java11",
                            "image": "openjdk:11",
                            "command": [command],
                            "args": [argument]
                        }
                    ]
                    }
                }
            }
        }

        deployment_patched = api.patch(
        body=deployment_manifest, name=deployment_name, namespace=namespace
        )

        print(deployment_patched)
        print(f"\n[INFO] deployment {deployment_name} updated\n")
        return f"\n[INFO] deployment {deployment_name} updated\n"

    update_deployment1()
    
    def deployment_restart2():

        #config.load_incluster_config()
        
        # Enter name of deployment and "namespace"

        v1_apps = client.AppsV1Api()

        now = datetime.datetime.utcnow()
        now = str(now.isoformat("T") + "Z")
        body = {
            'spec': {
                'template':{
                    'metadata': {
                        'annotations': {
                            'kubectl.kubernetes.io/restartedAt': now
                        }
                    }
                }
            }
        }
        try:
            deployment_restarted = v1_apps.patch_namespaced_deployment(deployment_name, namespace, body, pretty='true')
            print(deployment_restarted)
            return f"\n[INFO] deployment {deployment_name} restarted\n"


        except ApiException as e:
            print("Exception when calling AppsV1Api->read_namespaced_deployment_status: %s\n" % e)

    deployment_restart2()
    
    
    return f"\n[INFO] deployment {deployment_name} updated and restarted \n"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
    

